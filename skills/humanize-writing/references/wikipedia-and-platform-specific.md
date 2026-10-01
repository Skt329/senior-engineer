# Wikipedia and platform-specific cases

Read this when the user is writing for Wikipedia or a wiki, writing edit summaries, forum or discussion comments, unblock requests, user profile pages, or anything that uses wikitext. Most of the page "Signs of AI writing" was written for that setting, and the general rules in SKILL.md still apply on top of these.

## Contents

1. Wikitext vs Markdown
2. Hallucinated categories and templates
3. Edit summaries
4. Discussion and talk-page comments
5. Profile and user pages
6. Drafts submitted for review

---

## 1. Wikitext vs Markdown

Chatbots default to Markdown. Wikipedia uses wikitext. The mismatch is a strong tell, so convert correctly.

| Element | Markdown (wrong on a wiki) | Wikitext |
| --- | --- | --- |
| Heading | `# Title`, `## Section` | `== Section ==` |
| Bold | `**bold**` | `'''bold'''` |
| Italic | `*italic*` or `_italic_` | `''italic''` |
| External link | `[text](https://url)` | `[https://url text]` |
| Horizontal rule | `---` | `----` (and rarely needed) |
| Code fence | triple backticks | do not wrap article text in code fences |

Specific problems the guide documents:
- `##` used for headings renders as a numbered list in MediaWiki.
- Wikitext wrapped in a Markdown code block, with the literal "```wikitext" visible.
- A closing offer such as "Would you like me to turn this into actual Wikipedia markup?"
- Level-1 headings and skipped level-2 headings carried over from Markdown.
- Garbled `Template:AfC submission` code when a chatbot is asked how to submit a draft.

Do not add a title heading, since the page title already exists. Do not put `---` between sections. Use `==` headings in sentence case with text beneath each.

## 2. Hallucinated categories and templates

- Chatbots invent categories that do not exist (red links), or use obsolete or renamed ones, or drop punctuation (for example `American hip hop musicians` instead of `American hip-hop musicians`).
- They invent infobox types and parameters (for example `Infobox ancient population` instead of `Infobox archaeological culture`) and use deleted templates such as old `lang-??` ones.
- They place maintenance templates (short description, "Use American English", date tags) on new pages, and may pre-set `{{AfC submission|d}}`, which pre-declines a draft with no reasoning.

Only use categories, templates, and parameters you can confirm exist. If you cannot confirm, leave them out and say so.

## 3. Edit summaries

AI edit summaries follow templates that were uncommon before 2023. Signs:

- **Canned assurance of adherence to policy:** "ensured... adheres to", "complies with Wikipedia guidelines", "improved neutrality and verifiability", "refined", "enhanced", "streamlined", "encyclopedic tone", "clarity, flow." Several stacked in one summary is a stronger sign.
- **Procedural statements about what was preserved or avoided:** "while preserving the original meaning", "retained references", "avoided promotional language."
- **Overemphasis on sourcing:** "added sourced information", "with independent secondary sources", "improved attribution."
- **Itemized parameter and markup names:** "corrected infobox parameters (image_size)", "added inline citations and internal links."
- **Obvious reference to a review:** "addressed reviewer feedback."
- **Rule of three, emoji, Markdown, and first-person narration** in older examples, and chatbot preambles such as "Claude responded:" in the worst cases.

A human summary is short and says what changed in the content: "Added the 2019 debut album and chart position", "Removed duplicate paragraph", "ce" (copy edit), or "removed excessive links per MOS:OVERLINK." Write summaries like that. Do not announce that the edit complies with policy, and do not mention the obvious fact that it is for Wikipedia.

## 4. Discussion and talk-page comments

Signs that a comment was pasted from a chatbot, beyond the general tells:

- Misquoted policies and invented shortcuts that lead nowhere.
- Maintenance banners transcluded whenever they are mentioned.
- Long comments divided into titled sections, in Markdown, plain text, or subheadings.
- Itemized claims that the writer followed every policy, or that the comment "reflects my own thoughts."
- Requests for critics to say exactly what to improve.
- Dismissing concerns about AI origin as "speculation" without "concrete" evidence.
- Urging critics to focus on content rather than origin.
- Opening or closing formulas: "I understand your concern about...", "Dear Wikipedia Editorial Team:", "I hope this message finds you well."

Write comments in the person's own voice: short, direct, with specific diffs, quotes, or policy names that they have checked. A comment should not be longer than the point requires.

## 5. Profile and user pages

Canned AI profile pages use headings like "Welcome To My User Page!", "About Me", "My Interests", "Let's Connect!", emoji, bold text (or broken Markdown bold), and inline-header lists. Write a few plain sentences about what you edit and how to reach you.

## 6. Drafts submitted for review

Do not insert reviewer-facing "submission statements" arguing that the subject is notable and every source is independent. They do not help and they reveal the draft's origin. Let the sources and the prose carry the case. Do not leave notes to the user ("Delete this section before submission") inside the draft.
