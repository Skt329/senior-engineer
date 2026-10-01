# UX copy

Interface text should be short, specific, and in the user's language. Write it with the humanize-writing skill.

## Principles
- Say what happens, using the user's words, not the system's ("Save changes", not "Submit").
- Put the most important word first.
- Use sentence case for buttons, labels, and headings.
- Be consistent: one term per concept across the whole product.
- Be human and calm. No blame, no jokes in error messages, no exclamation marks in warnings.

## Buttons and links
Use a verb plus a noun when the verb alone is unclear: "Create project", "Download invoice". The button in a confirmation dialog repeats the action ("Delete project"), not "OK" or "Yes".

## Error messages
Say what happened, why if it helps, and what to do next.
- Bad: "Error 422: validation failed."
- Good: "That email is already registered. Sign in instead, or use a different email."
Show field errors next to the field, keep the user's input, and never show stack traces or error codes without an explanation.

## Empty states
Explain what will appear here and how to get started, with one primary action.
- "No invoices yet. Invoices you send will appear here." Button: "Create invoice".

## Confirmation dialogs
Use them only for destructive or irreversible actions. Title: the question ("Delete this project?"). Body: the consequence ("Its 12 tasks will be deleted. This cannot be undone."). Buttons: "Delete project" and "Cancel".

## Loading and progress
Say what is happening for anything longer than a second or two: "Uploading 3 of 10 photos".

## Success messages
Confirm briefly and offer the next step when there is an obvious one: "Invoice sent. View invoice".

## Forms
- Labels above fields, short and specific.
- Helper text for format rules before the user makes a mistake ("At least 8 characters").
- Mark optional fields rather than required ones when most fields are required.

## Notifications
Lead with the information, not the app's name: "Your order has shipped and arrives Thursday."
