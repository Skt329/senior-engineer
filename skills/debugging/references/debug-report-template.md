# Debug report template

Give this to the user when a bug is fixed, or when you stop at the loop breaker.

```markdown
## Bug: <one-line description>

Symptom: what the user saw, with the exact error message.
Reproduction: the steps or the failing test that triggers it.
Root cause: what was actually wrong, and why it produced this symptom.
Fix: what changed, and why it fixes the cause rather than the symptom.
Regression test: test name, and what it asserts.
Verification: commands run and their results.
Related risks: other places the same mistake may exist, if any.
```

If you stopped at the loop breaker, replace Fix and Regression test with:

```markdown
Attempts so far:
1. <what was tried> -> <what happened>
2. <what was tried> -> <what happened>
Current theory: <what you now believe, and the evidence>
What I need from you: <information, access, or a decision>
```
