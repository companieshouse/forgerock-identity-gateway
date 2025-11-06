# WebFiling ForgeRock Identity Gateway (IG) Functional Overview

This document explains the full functionality implemented by the `webfiling` ForgeRock Identity Gateway configuration. It covers route selection logic, authentication and session orchestration, protocol adaptation, language handling, legacy integration, and logout flows.

---
## High-Level Purpose
The WebFiling IG instance acts as an integration and orchestration layer between:
- ForgeRock Identity Cloud (FIDC / AM/OIDC) for modern identity, OpenID Connect, and session lifecycle.
- A legacy WebFiling application that expects credential-based form posts, host-specific redirects, and company-specific state.
- Supplemental journeys (company incorporation, payments, eReminders, iXBRL validation, static assets) routed through a reverse proxy.

IG performs the following major roles:
1. Terminates/initiates OAuth2/OpenID Connect flows and enriches them with journey-specific semantics (company selection, manage account, etc.).
2. Replays credentials (password/auth code/company details) from ID token claims into legacy POST forms to bootstrap legacy sessions (Password Replay pattern).
3. Normalizes and rewrites redirect targets for legacy and new hostnames (legacy vs current), including special mapping of sign-out flows.
4. Provides language persistence and propagation across OIDC redirections and legacy application navigation.
5. Exposes specialized dispatch bindings for different functional areas (eReminders, SCRS incorporation, payments, static assets, etc.).
6. Implements structured logout and end-session semantics across both FIDC and the legacy application, with conditional branching.

---
## Runtime Components (Heap Objects)
### ReverseProxyHandler
Primary upstream handler to forward requests to the `&{application.host}` origin. Configured with:
- TLS client options using `TrustAllManager` and `ALLOW_ALL` hostname verification (insecure; see recommendations).
- Connection/socket timeouts of 60 seconds.
- Request/response capture for diagnostics.

### SystemAndEnvSecretStore-FIDC
Provides client secret resolution (`oidc.client.secret`) from environment/system properties in plain format.

### Issuer-FIDC
Discovery of OIDC metadata via the well-known endpoint for the configured realm.

### ClientRegistration-FIDC
Defines an OIDC client using scopes: `openid profile email webfiling`. Uses `client_secret_post` token endpoint authentication. Captures registration for debugging (`regCapture`).

### regCapture (CaptureDecorator)
Entity capture for registration handler—instrumentation oriented, may log sensitive data if not filtered.

---
## Global Decorators
- `timer: true` — Performance timing.
- `capture: all` — Broad request/response capture (PII risk if logs are not filtered).

---
## Session Configuration
From `admin.json`: secure cookies enforced (`secure: true`). Session keys store OIDC artifacts; custom session fields include:
- `gotoTarget` — transient routing directive (manage account, companies list, logout, error).
- `ewfLanguage` — persisted user language preference.

---
## Route Files Overview
### 00-healthcheck.json
Condition: path matches `/healthcheck`. Returns static 200 `Healthy` response. Used for container/Kubernetes liveness and external monitoring.

### 01-legacy.json ("Legacy Web Filing")
Condition: host equals the legacy host `&{application.legacy.host}`.
Flow:
- ScriptableFilter `legacyRewriteHost.groovy` examines redirect `Location` headers and rewrites host prefixes from new to legacy domains.
- Rewrites `/signout` to `//com-logout?silent=1` to align with consolidated logout semantics.
- Transforms `file-for-another-company` URL into the legacy page `runpage?page=companyAuthorisation` when on the new host but legacy behavior expected.
Purpose: Provide backward compatibility surface while migrating to modern identity flows.

### 10-webfiling.json (Primary Dispatch)
Condition: all non-legacy hosts.
Defines a `DispatchHandler` with multiple `bindings`. Each binding evaluates a condition expression; first match processes the request through its handler (usually a simple Chain with optional filters). If no earlier binding matches, the comprehensive OIDC handler chain executes.

#### Binding Breakdown
1. **PAYMENTS-reverse-proxy** — Matches paths for submissions/payment endpoints (e.g., `/submissions`, `/paymentResource`). Straight proxy; no extra filters.
2. **EWF-eReminders / eReminders-email-click / eReminders-thankyou** — Query/path conditions around eReminder forms and email shortlink flows. Adds `CookieFilter` for language cookie management.
3. **SCRS-reverse-proxy** — Incorporation process (forms=INC, resume, accessibility, register, reminder, thankYou, memorandum). Plain proxy.
4. **SCRS-EMAILS-reverse-proxy** — Handles shortlink-based flows (`/com-shortlink`, password reset, help pages). Plain proxy.
5. **SCRS-FILE-UPLOAD-reverse-proxy** — File uploads gated by Referer containing incorporation form and query page=fileUpload.
6. **SCRS-testHarness** — Matches `page=jweHarness`; likely internal testing tool for encrypted payloads.
7. **SCRS-GOV-PAY / SCRS-PLUS-GOV-PAY** — Conditions based on cookie markers identifying active payment journeys (`application-in-progress` vs `journeyType=plus`) hitting `govPayResponseDispatcher`. Plain proxy.
8. **SCRS-SIGNOUT-reverse-proxy** — Supports sign-out when coming from incorporation referers. Prevents state leakage.
9. **iXBRL-reverse-proxy** — Validation endpoints (`/xbrl_validator`, `/xbrl`, `/xbrl_info`). NOTE: Condition has a syntax issue: `matches(request.uri.path, '^/xbrl' or matches(request.uri.path, '^/xbrl_info'))` — the `or` resides inside a `matches` call; should split into separate `matches(...) or matches(...)`. Potentially never matches `/xbrl` due to malformed expression.
10. **HTML-ASSETS-reverse-proxy** — Static asset routing (scripts, styles, images, favicon, etc.). Improves separation of dynamic vs static flows.
11. **footer-links-reverse-proxy** — Routes cookies policy, about WebFiling, accessibility statement.
12. **EWF-SCRSplus-lang-switch** — Language change operations for SCRS plus contexts.
13. **lang-logic** — General language switch endpoint (`/lang`). Applies `language.groovy` then manages cookies.
14. **file-for-a-company** — Invokes `start.groovy` to decide initial redirection based on presence of existing OIDC session (redirect to `com-logout` with `companySelect=1` if session exists; else drive to security login page `//seclogin`).
15. **request-auth-code / recent-filings** — Uses `postSecLoginRedirect.groovy` to prime a post-login redirect via a query flag (`postSecLoginRedirect=auth-code` / `recent-filings`).
16. **OIDC-Handler-Chain (catch-all)** — The most complex chain enabling identity enforcement and downstream adaptation.

---
## OIDC Handler Chain Filters (Detailed)
Order matters; each filter either transforms, short-circuits, or enriches the request/response.

1. **ForwardedRequestFilter** — Normalizes scheme/host/port from upstream proxy headers for correct absolute URL generation.
2. **authRedirect.groovy** — Central redirection logic. Functions:
   - Interprets incoming endpoints (`idam-logout`, `your-company-list`, `manage-your-account`, `file-for-another-company`, `file-for-a-company`) to set `session.gotoTarget`.
   - Detects company auth-code request completion and forces an error-page journey (for user messaging) by rewriting `Location`.
   - Builds login journey redirect with `ForceAuth=true` when selecting companies (`companySelect` flag), adding ACR values (`routeArgWebFilingComp`).
   - Routes to specific UI pages (companies list, manage account) if marked in query after OIDC authorization.
   - Integrates language parameter from session into all IDAM UI redirects.
3. **OAuth2ClientFilter-FIDC** — Initiates/validates OIDC flows. On failure triggers static redirect to `/oidc/logout` (clean session reinit). Disables token cache expiration for deterministic behavior.
4. **ConditionalFilter-com-signout** — Rewrites response `Location` header to silently logout (`/com-logout?silent=1`).
5. **ConditionalFilter-File-for-another-company / idam-logout** — Converts those paths into a static GET to application logout with flags (`companySelect=1`).
6. **ConditionalFilter-Manage-your-account / Your-companies** — Forces silent legacy logout to refresh context before entering manage-companies flows.
7. **ConditionalFilter-Com-logout** — Rewrites `Location` to OIDC logout endpoint with a crafted `goto` pointing back to `//seclogin` plus original query (encoded). Ensures FIDC RP-initiated logout cascades.
8. **ConditionalFilter-Com-logout-and-Company-Select-1** — When logging out without company-selection or management context, triggers `endSession.groovy` to call FIDC `/connect/endSession` for AM session termination.
9. **script.groovy** — Logs OpenID claims, updates session language if empty or coming from IDAM UI referer, exposes claim detail for troubleshooting.
10. **ConditionalFilter-SecLogin / CompanyAuthorisation** — On security login or company authorisation page failure, uses `errorRedirect.groovy` to route to a consistent IDAM UI error page with context and language.
11. **ConditionalFilter-SecLogin-and-PostSecLoginRedirect** — Applies `postSecLoginRedirect.groovy` logic to avoid double password replay and land user on target page (`companyWebFilingRegister` or `recentFilings`).
12. **PasswordReplayFilter-SecLogin** — Replays WebFiling password from ID token claim `webfiling_info.password` into legacy login form (`email`, `seccode`, `lang`). Bootstraps legacy session seamlessly after OIDC auth.
13. **PasswordReplayFilter-CompanyAuthorisation** — Replays company-specific authorization details including dynamic `__VIEWSTATE` extraction. Simulates a signed form POST for company linking.
14. **CookieFilter-Manage** — Central cookie governance to persist required session cookies while sanitizing or adjusting them.

---
## Groovy Script Functions Summary
| Script | Purpose |
|--------|---------|
| `authRedirect.groovy` | Complex OIDC authorize redirect shaping; session goto management; language propagation; company selection, manage account, and error-path overrides. |
| `endSession.groovy` | Performs back-channel logout request to AM `/connect/endSession` using `id_token_hint` and bearer access token, then continues chain. |
| `errorRedirect.groovy` | On failed password replay or login error, constructs deterministic redirect to IDAM UI error page with context (e.g. `seclogin`, `companyAuthorisation`). |
| `language.groovy` | Extracts `lang` query parameter, resets session language, persists new value. |
| `legacyRewriteHost.groovy` | Rewrites redirect locations from new to legacy host; maps signout to consolidated logout route; handles `file-for-another-company` transformation. |
| `postSecLoginRedirect.groovy` | Pre/post login redirect staging for auth code requests and recent filings; ensures single password replay cycle and correct landing page. |
| `script.groovy` | Diagnostic logging of OIDC claims and controlled session language initialization from token data. |
| `start.groovy` | Entry logic for `/file-for-a-company`; decides whether to force logout (if session exists) or send user to security login with company selection flag. |

---
## Language Handling Model
- `language.groovy` captures explicit changes via `/lang` endpoint.
- `script.groovy` sets language from ID token claims when session lacks a value or request originates from IDAM UI.
- Language parameter appended to redirects (auth journeys, companies page, manage account, error pages) ensuring UI localization continuity.

Session key: `session['ewfLanguage']` centralizes state.

---
## Company & Journey Selection
- `companySelect=1`, `yourCompanies`, `manageAccount` query flags processed by `authRedirect.groovy` to route to appropriate IDAM UI views or re-initiate auth with forced selection (ACR-based).
- Company authorization leverages password replay with viewstate extraction.
- `postSecLoginRedirect` flags ensure user is directed to contextually relevant pages immediately after secure login (auth code request confirmation or recent filings view).

---
## Logout & Session Termination Semantics
Multi-layered:
1. Local application logout endpoints mapped to `com-logout` or OIDC logout.
2. Conditional rewriting ensures presence of proper `goto` return path for re-auth flows.
3. When deeper termination required (no company selection context), `endSession.groovy` triggers FIDC end session endpoint.
4. Legacy host signout transformed to consolidated route for consistency.

---
## Security Considerations & Potential Risks
| Aspect | Observation | Recommendation |
|--------|-------------|----------------|
| TLS Trust | `TrustAllManager` & `ALLOW_ALL` hostname verification. | Replace with proper trust store and strict hostname verification. |
| Password Replay | Plain credentials (password, auth_code) in ID token claims. | Minimize sensitive claim lifetime; consider token exchange or service token pattern. |
| Capture Decorators | `capture: all` and entity capture can log PII. | Scope capture to non-sensitive metadata; scrub logs. |
| Scopes | Includes custom `webfiling` scope. | Ensure least privilege; audit associated claims. |
| iXBRL Condition | Malformed condition expression. | Correct logic: `matches(request.uri.path, '^/xbrl_validator') or matches(request.uri.path, '^/xbrl') or matches(request.uri.path, '^/xbrl_info')`. |
| Language Reset | Clearing `ewfLanguage` before parsing on `/lang`. | Acceptable; ensure no race conditions under concurrency. |
| Session gotoTarget | Transient manual state; risk of stale redirect if not cleared. | Already cleared post-use; maintain tests. |
| Query Parsing | Manual `split('&')` with naive `param.split('=')`. | Harden against empty segments and URL-encoding edge cases. |
| Multiple Leading Slashes | Paths like `//seclogin` and `///emailshortlink`. | Normalize incoming path to single leading slash; simplifies condition set integrity. |

---
## Maintainability Improvement Suggestions
1. Centralize route condition regexes/constants to reduce duplication of `matches(request.uri.path, '^//...')` patterns.
2. Introduce a utility Groovy library for query param parsing & URL building to avoid repeated manual encoding logic.
3. Refactor `authRedirect.groovy` into smaller functions (goto target processing, language injection, company selection) for readability and testability.
4. Implement structured unit tests for each ScriptableFilter using IG test harness (if available) or mock contexts.
5. Replace password replay with a token-mediated legacy session bootstrap (e.g., credential escrowing or backend exchange API) to eliminate sensitive claim usage.
6. Parameterize capture logging level so production can disable full entity capture without redeploy.
7. Add health/ready route expansions (e.g., `/ready`) to differentiate dependency readiness from container liveness.
8. Add explicit `Cache-Control` headers for static assets at the gateway layer if upstream lacks them.

---
## Data Flow Summary
1. User hits WebFiling entry (`/file-for-a-company`) → `start.groovy` decides redirect to login or silent logout then company selection.
2. User authenticates via FIDC OIDC journey (`authRedirect.groovy` shapes authorize URL, adds language, possible ACR values).
3. On successful OIDC, `OAuth2ClientFilter` obtains tokens; `script.groovy` logs and sets language.
4. `PasswordReplayFilter` replays credentials to legacy endpoint creating legacy session.
5. Navigation through functional routes (payments/SCRS/eReminders) passes through reverse proxy unaltered or enriched with language cookie management.
6. User triggers company authorization or additional flows; replay filters manage additional form posts.
7. Logout triggers conditional chain rewriting to ensure both legacy and FIDC sessions terminate properly; may include end-session back-channel call.

---
## Edge Cases & Handling
| Edge Case | Current Handling |
|-----------|------------------|
| Missing language on first redirect | Defaults to empty; later populated from ID token claims. |
| Auth code request leading to unintended company reuse | Special logic in `authRedirect.groovy` forces error path message. |
| Multiple rapid language switches | Session overwritten per `/lang` request. |
| Legacy host redirect loops | Host rewrite script ensures correct domain substitution. |
| Stale gotoTarget after logout | Cleared after use in `authRedirect.groovy`. |
| OIDC failure mid-flow | Failure handler redirects to `/oidc/logout` for clean restart. |

---
## Glossary
- **FIDC**: ForgeRock Identity Cloud (Authentication & OAuth2/OpenID Connect provider).
- **Password Replay**: IG pattern that simulates form submission to legacy app using identity provider token claims.
- **ACR Values**: Authentication Context Class References used to influence journey selection (e.g., company selection).
- **gotoTarget**: Session variable directing post-auth or post-logout navigation.
- **Journey**: ForgeRock authentication service chain (e.g., `CHWebFiling-Login`).

---
## Recommended Next Steps (Optional)
1. Remove insecure TLS trust configuration.
2. Fix iXBRL route condition expression.
3. Add automated tests for each scriptable filter (mock request/session/responses).
4. Substitute password replay with secure backend exchange to legacy system.
5. Introduce a policy-driven logging framework to reduce PII exposure.
6. Path normalization middleware to eliminate multi-slash variations.

---
## Conclusion
The WebFiling IG configuration is a sophisticated orchestration layer bridging modern OIDC identity with a legacy session-based application. It enriches authentication flows, centralizes language preference management, securely (though improvably) proxies diverse functional endpoints, and coordinates complex logout semantics. Targeted improvements around security hardening, maintainability, and correctness (notably TLS and path matching) will further strengthen the deployment.
