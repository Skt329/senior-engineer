# Testing web frontends: Vitest, Testing Library, Playwright

## Commands
Use the package.json scripts, for example `npm test`, `npm run test -- --coverage`, and `npx playwright test`.

## Unit and component tests
- Vitest (or the repository's Jest) with Testing Library.
- Query elements the way users find them: `getByRole`, `getByLabelText`, then `getByText`. Use test IDs only as a last resort.
- Use `userEvent` for interactions instead of firing raw events.
- Assert on what the user sees, not on component state or implementation details.

```tsx
it("shows an error when the email is invalid", async () => {
  render(<SignupForm />);
  await userEvent.type(screen.getByLabelText("Email"), "not-an-email");
  await userEvent.click(screen.getByRole("button", { name: "Sign up" }));
  expect(screen.getByRole("alert")).toHaveTextContent("Enter a valid email");
});
```

## Network
- Mock Service Worker (MSW) to stub API responses at the network layer, including errors and slow responses.

## End-to-end
- Playwright for a few critical journeys (sign in, the main task, payment). Run against a seeded test environment.
- Use role-based locators and web-first assertions (`await expect(locator).toBeVisible()`), never fixed sleeps.

## Accessibility
- Add axe checks (`@axe-core/playwright` or `vitest-axe`) on key pages and components, and keep keyboard-only checks in the manual test plan.

## Visual changes
- For UI work, capture before and after screenshots for the pull request. Add visual regression tests only if the repository already uses them.
