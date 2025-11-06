# WebFiling IG URL Coverage Overview

Comprehensive catalogue of every URL path (and query-trigger pattern) handled by the WebFiling ForgeRock Identity Gateway configuration. Includes:
1. Explicit route bindings (dispatch table in `10-webfiling.json`)
2. Legacy host route (`01-legacy.json`)
3. Healthcheck route (`00-healthcheck.json`)
4. Conditional filters inside the OIDC handler chain
5. Script-driven rewrites / generated targets
6. Query, header, and cookie based trigger semantics

---
## Host Variables
- Modern host: `https://&{application.host}`  
- Legacy host: `https://&{application.legacy.host}`  
- IG host (internal redirect construction): `https://&{ig.host}`  
- IDAM UI base: `&{ui.url}`

Multi-slash note: Conditions often match single and double leading slashes (e.g. `/lang` and `//lang`). Normalize to a single slash for future implementations.

---
## 1. Healthcheck Route
| Purpose | Pattern | Notes |
|---------|---------|-------|
| Liveness | `/healthcheck` | Static 200 "Healthy" response |

---
## 2. Legacy Host Route (`01-legacy.json`)
Activated only when request host equals `&{application.legacy.host}`.

Affected flows:
- Redirect `Location` headers beginning with `https://&{application.host}` rewritten to legacy prefix.
- `/signout` rewritten to `//com-logout?silent=1`.
- `file-for-another-company` path transformed to `runpage?page=companyAuthorisation` when legacy behavior expected.

Resulting legacy-visible URLs examples:
- `https://&{application.legacy.host}//com-logout?silent=1`
- `https://&{application.legacy.host}/runpage?page=companyAuthorisation`

---
## 3. Primary Dispatch (`10-webfiling.json`) — Route Bindings
Order of bindings matters; first match wins.

### 3.1 Payments & Submission APIs
| Binding | Paths (regex/contains) |
|---------|------------------------|
| PAYMENTS-reverse-proxy | `^/submissions`, `^/submissionData`, `^/paymentResource`, `^/authorisedFilersEmails` (single/double slash variants) |

### 3.2 eReminders Flows
| Binding | Trigger Type | Patterns |
|---------|--------------|----------|
| EWF-eReminders | Query contains: `form=eReminders`, `eReminder`, `form=eremActivate`, `form=eremActivateDone` |
| EWF-eReminders-email-click | Path: `/com-shortlink`, `//emailshortlink`, `/emailshortlink` AND query contains `eReminder` |
| EWF-eReminders-thankyou | Query contains: `form=eremThankyou` |

### 3.3 SCRS (Incorporation) Flows
| Binding | Patterns / Query Markers |
|---------|--------------------------|
| SCRS-reverse-proxy | Query contains: `form=INC`, `page=incOnlySCRSLogin`, `form=resumeIncorporation`, `page=scrsAccessibilityPage`, `page=register`, `page=reminder`, `page=thankYou`, `form=memorandum` OR path contains `/incorporation` |
| SCRS-EMAILS-reverse-proxy | Paths: `/com-shortlink`, `/resetpassword` (single/double), `/help` |
| SCRS-FILE-UPLOAD-reverse-proxy | Referer contains `form=INC` AND query `page=fileUpload` |
| SCRS-testHarness | Query contains `page=jweHarness` |
| SCRS-GOV-PAY-reverse-proxy | Cookie contains `register-your-company%2Fapplication-in-progress` AND path `/govPayResponseDispatcher` |
| SCRS-PLUS-GOV-PAY-reverse-proxy | Cookie contains `incorporation%3FjourneyType%3Dplus` AND path `/govPayResponseDispatcher` |
| SCRS-SIGNOUT-reverse-proxy | Path `/com-logout` with Referer containing incorporation markers |

### 3.4 iXBRL Validation
| Binding | Declared Condition |
|---------|--------------------|
| iXBRL-reverse-proxy | `^/xbrl_validator`, (intends also `/xbrl`, `/xbrl_info` but expression malformed) |

### 3.5 Static & Informational
| Binding | Patterns |
|---------|----------|
| HTML-ASSETS-reverse-proxy | `/scripts/`, `/style/`, `/stylesheets/`, `/javascripts/`, `/images/`, `favicon.ico` |
| footer-links-reverse-proxy | Path `/cookies` OR query `name=aboutWebFiling` / `name=accessibilityStatement` |

### 3.6 Language Switching
| Binding | Patterns |
|---------|----------|
| EWF-SCRSplus-lang-switch | Path `/lang` AND incorporation context markers |
| lang-logic | Path `/lang` (general language update) |

### 3.7 Entry / Post-Secure Login Helpers
| Binding | Paths |
|---------|-------|
| start.groovy | `/file-for-a-company` |
| postSecLoginRedirect.groovy | `/request-auth-code`, `/recent-filings` |

### 3.8 Catch-All OIDC Chain
All remaining unmatched paths processed by the comprehensive OIDC filter chain (see next section).

---
## 4. Paths & Queries Intercepted Inside the OIDC Handler Chain
| Mechanism | Match | Effect |
|-----------|-------|--------|
| com-signout | `/com-signout` | Rewrite Location → `/com-logout?silent=1` |
| file-for-another-company / idam-logout | `/file-for-another-company`, `/idam-logout` | Static GET to `.../com-logout?silent=1&companySelect=1` |
| manage-your-account | `/manage-your-account` (single/double) | Static GET logout + `manageAccount=1` |
| your-company-list | `/your-company-list` (single/double) | Static GET logout + `yourCompanies=1` |
| com-logout (header rewrite) | `/com-logout` | Location → `/oidc/logout?goto=...//seclogin...` |
| endSession path | `/com-logout` (no selection flags) | Calls AM endSession endpoint |
| SecLogin error redirect | `//seclogin` | On failure → IDAM UI error page |
| CompanyAuthorisation error | query `page=companyAuthorisation` | Error redirect with context |
| SecLogin post-login redirect | `//seclogin` + `postSecLoginRedirect=*` | Adjusts landing (auth code / recent filings) |
| PasswordReplay login | `//seclogin` | Form POST with email/password/lang |
| PasswordReplay company auth | query `page=companyAuthorisation` | Form POST with company_no/auth_code/jurisdiction/viewstate |
| gotoTarget setting | Selected endpoint tails | Prepares session redirect |
| companySelect journey | query `companySelect=1` | Forces ACR selection journey |
| manageAccount / yourCompanies | query flags | Direct UI page routing |
| postSecLoginRedirect suppress | query `postSecLoginRedirect=*` | Prevent default landing |
| auth code request completion | Redirect patterns | Force error page confirmation |
| language propagation | session `ewfLanguage` | Appended to UI redirects |
| OIDC claim logging | all | Diagnostic output |

---
## 5. Script-Generated / Constructed Target URLs
| Generated Target | Source |
|------------------|--------|
| `&{ui.url}&{login.path}?realm=...&service=...&authIndexValue=...&ForceAuth=true...` | `authRedirect.groovy` |
| `&{ui.url}&{logout.path}` | `authRedirect.groovy` |
| `&{ui.url}&{manage.path}` | `authRedirect.groovy` |
| `&{ui.url}&{companies.path}` | `authRedirect.groovy` |
| `&{ui.url}&{error.path}?context=...&companyNo=...&authCodeRequest=...` | `errorRedirect.groovy` / auth code branch |
| `https://&{application.host}/com-logout?silent=1&companySelect=1` (+ variants) | ConditionalFilters |
| `https://&{ig.host}//seclogin?postSecLoginRedirect=auth-code` → `//runpage?page=companyWebFilingRegister` | `postSecLoginRedirect.groovy` |
| `https://&{ig.host}//seclogin?postSecLoginRedirect=recent-filings` → `//runpage?page=recentFilings` | `postSecLoginRedirect.groovy` |
| `/com-logout?silent=1&companySelect=1` (relative) | `start.groovy` |
| `/oidc/logout?goto=...` | Com-logout header rewrite |
| `https://&{fidc.fqdn}/.../connect/endSession?id_token_hint=...` | `endSession.groovy` |
| Legacy host rewrite replacements (including `/signout` → `//com-logout?silent=1`) | `legacyRewriteHost.groovy` |

---
## 6. Query Parameter Flags
| Param | Meaning |
|-------|---------|
| `form=INC` | Incorporation journey |
| `form=eReminders`, `form=eremActivate`, `form=eremActivateDone`, `form=eremThankyou` | eReminder flows |
| `eReminder` | General eReminder presence |
| `form=resumeIncorporation` | Resume incorporation |
| `page=incOnlySCRSLogin` | SCRS login entry |
| `page=scrsAccessibilityPage` | Accessibility page |
| `page=register`, `page=reminder`, `page=thankYou` | Incorporation subpages |
| `form=memorandum` | Memorandum stage |
| `page=fileUpload` | File upload (with Referer) |
| `page=jweHarness` | Test harness |
| `companySelect=1` | Force company selection journey |
| `manageAccount=1` | Manage account navigation |
| `yourCompanies=1` | Companies list navigation |
| `postSecLoginRedirect=auth-code` / `recent-filings` | Target landing after secure login |
| `page=companyAuthorisation` | Company auth page / password replay |
| `lang=<code>` | Language override |
| `name=aboutWebFiling`, `name=accessibilityStatement` | Footer info pages |
| Dynamic: `companyNo`, `jurisdiction` | Passed into login journey |

---
## 7. Cookie / Header Driven Conditions
| Source | Usage |
|--------|-------|
| `Cookie` contains `register-your-company%2Fapplication-in-progress` | Payment journey binding |
| `Cookie` contains `incorporation%3FjourneyType%3Dplus` | Plus payment journey binding |
| `Referer` includes incorporation markers | SCRS signout binding |
| `Referer` + `page=fileUpload` | File upload binding |
| `Referer` contains `idam-ui` | Language re-sync in `script.groovy` |
| `Location` header (response) | Redirect rewrites (login/logout/legacy host) |

---
## 8. Canonical Path Set (Deduplicated)
```
/healthcheck
/submissions
/submissionData
/paymentResource
/authorisedFilersEmails
/com-shortlink
/emailshortlink
/resetpassword
/help
/govPayResponseDispatcher
/incorporation*
/xbrl_validator
/xbrl        (intended)
/xbrl_info    (intended)
/scripts/*
/style/*
/stylesheets/*
/javascripts/*
/images/*
/favicon.ico
/cookies
/lang
/file-for-a-company
/file-for-another-company
/request-auth-code
/recent-filings
/com-signout
/com-logout
/your-company-list
/manage-your-account
/idam-logout
/seclogin
/runpage?page=companyAuthorisation
/runpage?page=companyWebFilingRegister
/runpage?page=recentFilings
```

Query-driven overlays (same base paths):
```
?page=incOnlySCRSLogin
?page=fileUpload
?page=jweHarness
?form=INC
?form=eReminders
?form=eremActivate
?form=eremActivateDone
?form=eremThankyou
?form=resumeIncorporation
?form=memorandum
?companySelect=1
?manageAccount=1
?yourCompanies=1
?postSecLoginRedirect=auth-code
?postSecLoginRedirect=recent-filings
?page=companyAuthorisation
?lang=<code>
?name=aboutWebFiling
?name=accessibilityStatement
```
Generated targets:
```
/oidc/logout
/account/login (part of IDAM UI path)
/connect/endSession
/com-logout?silent=1&companySelect=1
/com-logout?silent=1&manageAccount=1
/com-logout?silent=1&yourCompanies=1
```

---
## 9. Impact Summary for Migration
Must replicate or replace:
1. **Authentication orchestration** (login journey shaping, ACR values, ForceAuth, goto, language).
2. **Password replay** (replace with secure backend session bootstrap).
3. **Complex logout semantics** (multi-flag conditioned redirects + endSession).
4. **Company & journey routing flags** (`companySelect`, `manageAccount`, `yourCompanies`, `postSecLoginRedirect`).
5. **Language persistence/propagation** (session → redirects).
6. **Legacy host rewriting / signout transformation**.
7. **Query/Referer/Cookie binding logic for incorporation & payment flows**.
8. **Error handling redirects with contextual parameters**.
9. **Static asset routing consistency**.

---
## 10. Anomalies / Cleanup Opportunities
| Item | Description | Recommendation |
|------|-------------|---------------|
| Multi-slash paths | `/path` vs `//path` duplicates | Normalize to single slash |
| iXBRL condition bug | Misplaced `or` in `matches` | Fix expression to separate matches |
| Password replay | Sensitive claims used directly | Replace with service-side exchange |
| TLS trust (outside URL scope) | `TrustAllManager` + `ALLOW_ALL` | Enforce proper trust store |

---
## 11. Decommission Checklist
- Enumerate canonical paths and classify (proxy / rewrite / retire).
- Replace `gotoTarget` and `ewfLanguage` with native app/session concepts.
- Implement secure session bridging instead of password replay.
- Port language propagation (query param or header approach).
- Reproduce logout & company selection flows.
- Fix malformed conditions before migration for clarity.
- Reduce dependency on Referer/Cookie if possible (move to explicit state).

---
## 12. Summary
The WebFiling IG mediates a broad set of functional endpoints, layering authentication journeys, company selection, language management, and legacy compatibility atop a reverse proxy core. Every path above should be reviewed to determine ownership (legacy app vs identity UI) and required behavior when IG is removed.

---
*End of URL Coverage Overview.*
