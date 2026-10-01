# Signs of AI writing: full catalog

Source: Wikipedia, "Signs of AI writing" (WP:AISIGNS, WikiProject AI Cleanup advice page), read in full for this skill. The page is descriptive, not prescriptive. It also says that no single sign proves AI use, that these patterns regress toward the average, and that signs are symptoms of deeper problems (generic, unverified content). Use this catalog to find and fix patterns, not to chase a score.

## Contents

1. Content patterns
2. Language and grammar
3. Style and formatting
4. Communication aimed at the user
5. Markup leaks from specific tools
6. Citations and references
7. Edit summaries and comments (short pointer)
8. Other signals
9. Things that are NOT reliable tells
10. Historical indicators (older models)
11. Differences between models
12. Biases in content

---

## 1. Content patterns

### 1.1 Undue emphasis on significance, legacy, and broader trends

Words to watch: stands/serves as, is a testament/reminder, a crucial/pivotal/vital/significant/key role/moment, underscores/highlights its importance/significance, reflects broader, symbolizing its ongoing/enduring/lasting, contributing to the, setting the stage for, marking/shaping the, represents/marks a shift, key turning point, evolving landscape, focal point, indelible mark, deeply rooted.

Variants:
- Situating the subject amid broader "debates", or saying it "participated in public discussions."
- Hedging preambles that admit low importance, then claim importance anyway.
- Applying significance language to mundane things such as etymology or population data.
- Biology: over-emphasizing ties to the wider ecosystem, belaboring conservation status and "research and preservation efforts" even when status is unknown and no efforts exist.

Fix: state the specific fact. Delete the sentence if the only thing it adds is "this matters."

### 1.2 Canned emphasis on notability, attribution, and media coverage

Words to watch: independent coverage, local/regional/national/[country] media outlets, music/business/tech outlets, trade publications, cited/featured/profiled in, written by a leading expert, active social media presence, was identified by.

The model proves importance by describing the kinds of sources that covered the subject. It often credits its own shallow analysis to a source that never said it. More common in text from tools released in 2025 or later. "Maintains an active social media presence" is especially idiosyncratic to AI.

Fix: name one real source and say what it reported. Drop the rest.

### 1.3 Superficial analyses

Words to watch: highlighting/underscoring/emphasizing ..., ensuring ..., reflecting/symbolizing ..., contributing to ..., cultivating/fostering ..., encompassing ..., enhancing ..., valuable insights, align/resonate with.

Pattern: a present-participle phrase tacked onto the end of a sentence to supply commentary on significance. Newer tools with web access may attach it to a named source ("Roger Ebert highlighted the lasting influence") whether or not that source said it.

Fix: end the sentence at the fact. Give any real analysis its own sentence and its own support.

### 1.4 Promotional and advertisement-like language

Words to watch: boasts a, vibrant, rich, profound, enhancing, showcasing, exemplifies, commitment to, natural beauty, nestled, in the heart of, groundbreaking, renowned, featuring, diverse array.

Output drifts toward travel-guide or press-release prose even when asked for a neutral tone, and even when rewriting text to "remove promotional tone." Cultural-heritage topics get repeated reminders of importance. People and companies get a commercial tone. Older models (GPT-4) were blatantly positive. Newer ones are subtly positive and avoid obvious superlatives like "the best."

Fix: figures, dates, names, and plain description.

### 1.5 Vague expression of connection or association

Words to watch: in connection with/to, connected with/to, in association with, associated with.

"In 2017, sources identified John Doe as being associated with leadership of ExampleCorp" instead of "In 2017, John Doe was CEO of ExampleCorp." Often stacked with buzzwords ("particularly/widely associated").

Fix: say what the relationship actually is.

### 1.6 Vague attributions and overgeneralized opinions

Words to watch: Industry reports, Observers have cited, Experts argue, Some critics argue, several sources/publications (when few are cited), "such as" before an exhaustive list.

Also: exaggerating the number of sources, presenting one or two sources' views as widely held, mentioning multiple "reviewers" or "scholars" while citing one, and implying a list is open-ended when it is not.

Fix: name the source, count honestly, own the opinion, or cut it.

### 1.7 Outline-like conclusions about challenges and future prospects

Words to watch: Despite its... faces several challenges..., Despite these challenges, Challenges and Legacy, Future Outlook.

A rigid closing formula: praise, then "challenges," then a vaguely positive assessment or speculation about initiatives that could help. The sign is the rigid formula, not the mere mention of challenges.

Fix: real, specific problems in the body; no formulaic upbeat coda.

### 1.8 "X and Y" headings and "Awards and recognition"

Headings in "X and Y" form are common in AI text. "Awards and recognition" (or "Recognition") is nearly ubiquitous, even compared with promotional human-written articles.

Fix: name the section for its contents. List awards by year and body.

---

## 2. Language and grammar

### 2.1 High density of "AI vocabulary"

Master list: Additionally (especially opening a sentence), align with, boasts (meaning "has"), bolstered, crucial, deep dive, delve, emphasizing, enduring, enhance, fostering, garner, highlight (verb), interplay, intricate/intricacies, key (adjective), landscape (abstract noun), meticulous/meticulously, pivotal, robust, showcase, tapestry (abstract noun), testament, underscore (verb), valuable, vibrant.

These words rose sharply in text after 2022 and cluster together. One or two can be coincidence. Many, repeated, is among the strongest tells.

By era (approximate):

| Period | Model family | Words that cluster |
| --- | --- | --- |
| 2023 to mid-2024 | GPT-4 | Additionally, boasts, bolstered, crucial, delve, emphasizing, enduring, garner, intricate/intricacies, interplay, key, landscape, meticulous(ly), pivotal, underscore, tapestry, testament, valuable, vibrant |
| Mid-2024 to mid-2025 | GPT-4o | align with, bolstered, crucial, emphasizing, enhance, enduring, fostering, highlighting, pivotal, showcasing, underscore, vibrant |
| Mid-2025 onward | GPT-5 | emphasizing, enhance, highlighting, showcasing, plus the notability and media-coverage phrases in 1.2 |

"Delve" peaked in 2023 to early 2024 and dropped off sharply in 2025. Grok overuses superficially scientific words (causal, empirical, correlate) and still overuses "underscore" as of 2026.

Cautions from the guide: take the list literally. An overused word does not make its synonyms overused. Context matters: "underscore" can mean the character or incidental music.

### 2.2 Avoidance of basic copulatives

Words to watch: serves as / stands as / marks / functions as / operates as / represents [a], boasts / features / maintains / offers [a], refers to.

Studies found over 10% fewer "is" and "are" in academic writing in 2023. AI copyedits "improve" plain sentences this way. In lead sentences, "refers to" appears as if the article were about a word. More elaborate forms: "ventured into politics as a candidate" for "was a candidate", "began his career as" for "was."

Example: "Gallery 825... is LAAA's exhibition arm. There are four gallery spaces" became "serves as LAAA's exhibition space... The gallery features four separate spaces."

Fix: is, are, has.

### 2.3 Negative parallelisms

- Not just X, but also Y: "Not only... but...", "It is not just..., it's..."
- Not X, but Y: "It's not..., it's...", "no..., no..., just..."
- Y rather than X: reversed form, common in Grok, present in ChatGPT and Claude: "prioritizing empirical consolidation of power... rather than ideological purity."

Can span sentences ("He hailed from the esteemed Duse family... Eugenio's life, however, took a path that intertwined both personal ambition and familial complexities."). Common among humans in myth-busting listicles, but stereotypically an AI sign.

Fix: state the positive claim directly. Use contrast only against a view someone actually holds.

### 2.4 Leads that treat list titles or broad topics as proper nouns

First sentences that define the page title as if it were a real-world entity ("EuroGames editions refers to...").

### 2.5 Rule of three

"Adjective, adjective, adjective" and "short phrase, short phrase, and short phrase." Stronger when it shows up where no one bothers with flourish, such as edit summaries. Also visible in canned bullet lists with parallel triples.

### 2.6 Syntax: what humans do more than AI

Observed as more common in human-written text than in AI text:
- Simple is/has phrases: "there is a", "it has a".
- Plain words over stiff or euphemistic synonyms: wrote (authored), moved (relocated), used (utilized), tried (attempted), died (passed away).
- Superlative or definitive statements: one of the best, is the only, was the first.
- Hedging qualifiers and intensifiers: very, perhaps, tends to.
- Plain wordy constructions: as a result of, in order to, all of the, a part of, the fact that.

So stiffness, euphemism, and the absence of any hedging are the warning signs. Keep natural plain phrasing.

---

## 3. Style and formatting

| Sign | What it looks like | Fix |
| --- | --- | --- |
| Title heading | A heading with the article's name before all content | Omit it unless the format needs it |
| Title Case headings | "Impact of Technology and Digitalization" | Sentence case |
| Headings containing only headings | A heading directly followed by another heading | Put text under each heading, or merge |
| Overuse of boldface | Mechanical bolding of key terms, "key takeaways" style | Bold rarely |
| Inline-header vertical lists | Bullet or number, then **Bold header**: description | Prose, or plain list |
| Em dashes | Used where commas, colons, or parentheses fit; often spaced; formulaic "punch" contrasts | Rewrite without them |
| Emoji as formatting | Emoji before headings or bullets | Remove |
| Unusual tables | Tiny, minimally formatted tables that prose or an infobox would handle | Use prose |
| Curly quotes and apostrophes | ChatGPT and DeepSeek often use " " ' '; sometimes mixed with straight | One consistent style; straight in plain text |
| Skipped heading levels | Jumping to level 3 without level 2 | Follow hierarchy |
| Level-1 headings | Markdown `#` carried over | Use level 2 and below inside documents |
| Thematic breaks | `---` between every section | Remove |

Notes from the guide: em-dash overuse is "somewhat notorious," some vendors suppressed it (GPT-5.1), and a July 2026 study found that among contemporary models only Claude used em dashes more than professional writers. The sign is best read together with others. Curly quotes alone prove nothing (Word, macOS, iOS, and professional typesetting all produce them), and Gemini and Claude typically do not use them.

---

## 4. Communication aimed at the user

### 4.1 Collaborative communication

Words to watch: I hope this helps, Of course!, Certainly!, You're absolutely right!, Would you like..., is there anything else, let me know, more detailed breakdown, here is a...

Text meant as correspondence or prewriting ends up pasted into the deliverable. Includes offers to reformat ("Would you like me to turn this into...?"), submission notes, and advice that is often wrong.

### 4.2 Knowledge-cutoff and source-availability disclaimers

Words to watch: Up to my last training update, as of my last knowledge update, While specific details are limited/scarce..., not widely available/documented/disclosed, ...in the provided/available sources / search results..., [claim] should be treated as... rather than..., based on available information.

Older models cited their cutoff date. Models with retrieval claim information is "not publicly available," then speculate about what it "likely" is. For people, this appears as "maintains a low profile" or "keeps personal details private", which is speculative. As of 2026, models also add source-use warnings built as negative parallelisms ("should be treated as religious tradition rather than as an archaeological explanation").

### 4.3 Phrasal templates and placeholder text

Fill-in-the-blank text left unfilled: "[Entertainer's Name]", "(Add your channel URL here)", "(If available)", date placeholders like `2025-xx-xx`, and comments such as `<!-- Add if available with citation -->`.

---

## 5. Markup leaks from specific tools

These are near-certain evidence the text was pasted from a chatbot. Remove them.

- **ChatGPT:** `contentReference`, `oaicite`, `oai_citation`, `+1` after a name, `turn0search0` (and `turn0image0`, `turn0news0`, `turn1file0`) often wrapped in private-use Unicode characters, JSON like `({"attribution":{"attributableIndex":"X-Y"}})`.
- **Gemini:** `[cite: 1]`, `[cite: 3, 12, 13]`, `[span_1](start_span)`, `[span_1](end_span)`.
- **Grok:** `grok_card` tags, `grok_render_citation_card_json`.
- **DeepSeek:** lenticular brackets with dagger symbols, such as `【85†L261-269】`.
- **Perplexity:** `[attached_file:1]`, `[web:1]`, `ppl-ai-file-upload` in URLs.
- **Unclassified:** `:::writing{variant="document" id="NNNNN"}` with trailing `:::`.
- **Tracking parameters in URLs:** `utm_source=openai`, `utm_source=chatgpt.com`, `utm_source=copilot.com`, `referrer=grok.com`. These prove a chatbot surfaced the link, not that it wrote the prose, but remove them from links anyway.
- **Markdown in a non-Markdown destination:** `**bold**`, `##` headings, fenced code blocks, backtick-wrapped text pasted into plain email, wikitext, or a CMS that does not render it.

---

## 6. Citations and references

- **Broken external links:** several dead links in a new document, not found in web archives, suggests they never existed.
- **Invalid DOIs and ISBNs:** unresolvable DOIs, ISBNs that fail the checksum.
- **DOIs that lead to unrelated articles:** a plausible-looking citation whose DOI resolves to a different paper. In the guide's example, two fabricated Proceedings of the IEEE references about Ohm's law had real-looking DOIs belonging to other papers, and one named author had died decades before the claimed date.
- **Book citations without page numbers**, or with page numbers where the cited page does not support the claim, especially for general, frequently cited books with no URL.
- **Unused or undefined named references** in reference lists.
- **Wrong reference-reuse syntax** repeated after every sentence; a stray "return" arrow (↩) around footnotes.
- **Overemphasis on citations** as a topic: prose that talks about the sources rather than using them.

Rule: cite only what you can verify. If you cannot verify, state the claim without a citation or flag it for the user.

---

## 7. Edit summaries and comments (short pointer)

Details are in `wikipedia-and-platform-specific.md`. In brief: AI edit summaries and comments over-assure ("ensured neutrality", "complies with guidelines"), mention what was "preserved" or "avoided", stress that content is "sourced", itemize parameter names, and cite reviewer feedback obviously. Human summaries are short and specific about what changed.

---

## 8. Other signals

- **Sudden shift in style:** unexpectedly flawless prose compared with the writer's other messages, especially if their earlier writing predates November 2022. A consistent style before and after is evidence of human authorship.
- **English-variety mismatch:** American spelling for an Indian, British, or other subject or writer. LLMs default to American English unless told otherwise. Non-native writers also mix varieties, so this matters only with a dramatic, unexplained shift.
- **Style that tracks the AI era:** a writer's 2023 text resembles 2023 LLM output, their 2025 text resembles 2025 output.
- **Inability to explain choices:** a person should be able to say why they wrote or cited something.
- **Reviewer "submission statements"** inserted by the model to argue the draft meets notability rules.
- **Canned profile pages:** "About Me", "My Interests", "Let's Connect!", emoji, inline-header bullets.
- **Pre-placed maintenance templates** that should not plausibly exist.

---

## 9. Things that are NOT reliable tells

The guide lists these as ineffective, and some may point the other way. Do not "fix" them:

- Perfect grammar.
- A mix of casual and formal registers, or language that is both clinical and emotional.
- "Bland" or "robotic" prose in general (AI output has specific traits, and prose can be bland without being AI).
- Fancy, academic, or formal prose in general (only specific words are overrepresented).
- Transition words in isolation (Additionally, Consequently, Notably). Only a few are known overused, and essay-style human writing uses them.
- Unsourced content.
- Correct markup or formatting.
- Odd, random-looking markup errors (these point to editor bugs, not LLMs).

---

## 10. Historical indicators (older models, 2022 to 2024)

Less common now, still worth removing:
- **Didactic disclaimers:** "it's important/critical/crucial to note/remember/consider", "worth noting", "may vary", advice to an imagined reader about safety or jurisdictions.
- **Section summaries and conclusions:** "In summary", "In conclusion", "Overall", and ending paragraphs by restating their idea.
- **Prompt refusals:** "As an AI language model", "I cannot offer medical advice, but I can...", "I'm sorry...".
- **Abrupt cut-offs** from token limits.
- **Outdated access dates** in citations.
- **Elegant variation:** repetition-penalized models rotate synonyms for the same referent ("Soviet artistic constraints", "non-conformist artists", "their creativity") instead of repeating a word. Note that some human writers, taught in school to avoid repetition, do the same.

---

## 11. Differences between models

Each model and version has its own idiolect. What marks GPT-5 differs from GPT-4 or Gemini. In the guide's comparison, ChatGPT (GPT-4o era) and Grok show more focus on broader context, while Gemini and Claude responses tend to be more concise. Do not assume one profile fits all text. Grok output is distinctive for its pseudo-scientific vocabulary. ChatGPT and DeepSeek lean on curly quotes. Gemini and Claude typically do not.

---

## 12. Biases in content

Even large American frontier models show, on a number of prompts as of 2026, a pro-authoritarian bias, partly from training on unfiltered internet text including state media and partly from safety rationales. Chinese-language answers lean more authoritarian than English ones, and models criticize freer governments more readily than repressive ones. When writing on politically sensitive subjects, verify framing against independent sources.
