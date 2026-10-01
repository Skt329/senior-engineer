# Test plan template

Add this to the plan for major tasks, under Verification.

```markdown
## Test plan

Scope: <what this change does that needs proving>

| Behavior | Level | Test name | Data or fixture |
|---|---|---|---|
| Refresh returns a new access token | integration | test_refresh_returns_new_access_token | user_with_refresh_token |
| Reused refresh token is rejected | unit | test_reused_refresh_token_is_rejected | none |
| Expired refresh token returns 401 | integration | test_expired_refresh_token_returns_401 | frozen clock |

Failure paths covered: invalid input, missing record, permission denied, timeout, duplicate delivery.

Test data: factories or fixtures to add, and how they are cleaned up.

Manual checks:
1. <step> -> <expected result>

Commands:
- `<run the new tests>` -> expected <n> passed
- `<run the full suite>` -> expected no failures
```
