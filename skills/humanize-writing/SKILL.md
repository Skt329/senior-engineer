---
name: humanize-writing
description: Write or rewrite text so it reads like a specific, knowledgeable person wrote it instead of an AI chatbot. Built from Wikipedia's "Signs of AI writing" field guide (WikiProject AI Cleanup). Covers AI vocabulary (delve, tapestry, pivotal, testament, vibrant), inflated significance and legacy talk, promotional tone, "not just X, but Y" constructions, rule-of-three padding, tacked-on "-ing" analysis, vague attributions ("experts argue"), bold-header bullet lists, em dashes, emoji, title-case headings, chatbot chatter ("Certainly!", "I hope this helps"), knowledge-cutoff disclaimers, "in conclusion" endings, leaked citation markup, and fabricated references. Use this skill whenever the user asks to humanize, de-AI, or "make this sound natural/human", pastes text and asks why it sounds like AI, or asks for emails, essays, blog posts, LinkedIn posts, reports, cover letters, bios, product copy, documentation, or any prose where natural human tone matters, even if they never mention Wikipedia or AI detection.
---

# Humanize writing

Write and rewrite text so it reads like a specific person with real knowledge wrote it, not a chatbot on autopilot. The rules come from Wikipedia's field guide "Signs of AI writing", which catalogs the habits that make LLM text recognizable. This skill turns that catalog into things to avoid and things to do instead.

## Why the tells exist (read this first)

LLMs predict the most statistically likely next words, so their output drifts toward the average of everything they have read. Specific, unusual facts get swapped for generic, positive, important-sounding statements. "Inventor of the first train-coupling device" becomes "a revolutionary titan of industry." Nearly every sign in the guide is a side effect of this: inflated significance, vague attributions, tacked-on analysis, promotional adjectives, padding in threes.

Two consequences shape everything below.

1. **The cure is specificity.** Replace vague with concrete: who, what, when, how many, according to which source. Swapping "delve" for "dive into" fixes nothing. The guide is explicit that an overused word does not make its synonyms overused, and the emptiness underneath stays.
2. **The signs are symptoms, not the disease.** The guide warns against treating them as the problem. They point to thin, generic, unverified content. If you delete a flourish and nothing of substance is left, the sentence never had content. Cut it, or get a real fact to put there.

## Ground rules

- **Never invent to sound human.** No made-up anecdotes, quotes, statistics, personal experiences, sources, or citations. Fabricated detail is worse than generic prose. If a passage needs a real detail you do not have, say so in a short note after the text and ask for it.
- **Preserve meaning and the user's facts.** Rewriting changes how things are said. It does not add claims, soften findings, or change numbers.
- **Do not over-correct.** The guide lists things that are not reliable tells: correct grammar, formal or "fancy" vocabulary in general, mixed casual and formal registers, transition words in isolation, bland prose, and correct markup. Do not add typos, slang, or fake roughness. Keep clean grammar and keep a word if it is the right word.
- **Match the person.** If the user gives a writing sample, mirror its sentence length, punctuation habits, vocabulary, and tone. Use the variety of English the audience expects (British, Indian, American, and so on). LLMs default to American English, and a mismatch between writer, topic, and spelling is itself a tell.
- **Be honest about the goal.** Detectors have real error rates and humans are poor at spotting AI text, so the goal is better writing, not a detector score. If the user's setting requires disclosing AI help (a course, a journal, a platform rule), that obligation stays with them. Say so briefly only if it comes up.

## Workflow

### A. Writing something new

1. **Gather the concrete material first.** Audience, purpose, and the three to five real facts, examples, numbers, or details the piece rests on. If the user supplied none, ask for them or write only what is actually known. Do not pad to reach length.
2. **Lead with the point.** No warm-up, no restating the request, no announcing what you are about to say.
3. **Say each thing once, plainly.** Use the simplest accurate word. Use "is", "are", and "has" where they fit. Repeat a noun rather than rotating through fancy synonyms for it.
4. **Own judgments or attribute them precisely.** Write "I think the second option costs less because..." or name the actual source. Do not hand opinions to "experts", "observers", or "many".
5. **Match structure to content.** Prose by default. Use a list only when the items are truly parallel and separate. Use a table only for real tabular data.
6. **Stop when the content ends.** No closing summary, no "in conclusion", no offer of further help inside the deliverable.
7. **Run the audit** (below).

### B. Rewriting existing text

1. **Read for purpose and facts.** Note which facts are solid and which sentences are carrying no information.
2. **Map the problems.** Run the scanner if a shell is available:
   `python scripts/scan_ai_tells.py draft.txt` (or pipe text in). It flags vocabulary, phrasing, formatting, and leaked markup with line numbers. It cannot see semantic problems such as vague claims, empty analysis, or elegant variation, so also read the text against the rules below.
3. **Fix each flagged passage by asking what the concrete claim is.** Then choose one:
   - restate it plainly, with the same facts;
   - make it specific using details already in the text or supplied by the user;
   - delete it, if it only gestures at importance;
   - mark it as needing a real detail, and list that in the note.
4. **Fix the format.** Remove any title heading echoing the topic, turn bold-label bullets into prose, put headings in sentence case, replace em dashes, drop emoji and decorative rules, strip chatbot framing and closing summaries.
5. **Check rhythm.** Mix short and long sentences because the content calls for it, not as a gimmick. Uniform sentence shape across a whole piece reads as machine-made.
6. **Re-scan and re-read.** Confirm no fact changed and no new tells crept in. Replacing one tell with its cousin ("pivotal" to "key", "tapestry" to "mosaic") counts as a miss.

### C. Audit before delivering (new or rewritten)

- Could any sentence be pasted into an article about a different subject and still work? If so, it is generic. Make it specific or cut it.
- Is there a significance claim ("testament", "pivotal", "broader landscape", "enduring legacy") that no fact supports?
- Does any sentence end with a "-ing" phrase that adds commentary (", highlighting...", ", ensuring...", ", reflecting...")?
- Any "not just X, but Y", "it's not X, it's Y", or "no X, no Y, just Z"?
- Lists of three where the facts have two or four items?
- "Serves as", "stands as", "boasts", "features", "offers" where "is" or "has" works?
- Attributions to unnamed experts, critics, reports, or "several sources"?
- Bold labels, bullets, emoji, tables, or headings that the content does not need?
- Em dashes? Replace with a comma, colon, period, or parentheses.
- Any chatbot residue: "Certainly!", "I hope this helps", "Let me know", "Would you like...", knowledge-cutoff or source-availability disclaimers?
- Any citation, link, DOI, quote, or statistic you cannot verify? Remove it or flag it.

## Output format

Deliver the text first, clean and ready to use. Follow it with a short note (two to five lines) covering only what the user needs to act on: details that need a real fact from them, claims or citations that could not be verified, and anything cut because it carried no information. Do not narrate every edit unless asked.

## The rules, by category

Each rule says what to avoid, why it reads as AI, and what to do. `references/signs-catalog.md` has the full word lists, regex-style phrase patterns, per-model era notes, and more variants. Read it when rewriting heavy AI text, when the user wants a thorough audit, or when a pattern here needs more detail. `references/before-after.md` has worked examples. `references/wikipedia-and-platform-specific.md` covers wikitext, edit summaries, talk-page comments, and similar platform-specific cases.

### 1. Content patterns

**Inflated significance and legacy.** Phrases like "stands as a testament to", "plays a pivotal role in", "underscores its importance", "reflects broader trends", "an evolving landscape", "indelible mark", "setting the stage for". The model inflates how much arbitrary details matter to some bigger story. Do instead: state what happened and let the reader judge its weight. "It was the first X in Y, and Z later copied the design" beats "a pivotal moment in the evolution of Y." Skip significance for mundane facts like etymology or population counts. Do not situate a subject amid vague "debates" or say it "participated in public discussions."

**Canned notability.** "Independent coverage", "featured in regional and national media outlets", "a leading expert", "maintains an active social media presence". It describes the sources instead of using them. Do instead: say what a specific, named source reported, or leave it out.

**Superficial "-ing" analysis.** A sentence states a fact, then trails off into ", highlighting its importance", ", ensuring a seamless experience", ", reflecting broader trends", ", fostering a sense of community". Do instead: end the sentence at the fact. If analysis is warranted, make it its own sentence with a real claim and a reason, or attribute it to the person who actually said it.

**Promotional tone.** "Boasts a vibrant", "rich cultural heritage", "nestled in the heart of", "groundbreaking", "renowned", "diverse array", "commitment to excellence". Newer models are subtler, so also watch for quiet positivity. Do instead: neutral description with figures, dates, and names. Drop adjectives that only add approval.

**Vague connections.** "Associated with", "connected to", "in connection with" in place of a stated relationship. Do instead: "was CEO of ExampleCorp in 2017", "taught chemistry at Example University."

**Weasel attribution.** "Industry reports suggest", "experts argue", "some critics say", "several sources". Models also overstate how many sources hold a view, or imply a list is incomplete ("such as...") when it is complete. Do instead: name the source, or say it is your own view, or cut it. Say "two reviewers" when there are two.

**Formulaic challenges and outlook endings.** "Despite its success, X faces several challenges... Despite these challenges, X remains well positioned." Also sections titled "Challenges and Legacy" or "Future Outlook." Do instead: put real problems, with specifics, where they belong. End when the content ends, not on an upbeat forecast.

**Reflexive "X and Y" and "Awards and recognition" headings.** Name sections for what they contain. List awards with the year and the awarding body.

**Biology and place filler.** Do not tie a species to "the broader ecosystem", belabor conservation status, or praise a town's "natural beauty" unless the facts are there and sourced.

### 2. Language and grammar

**AI vocabulary.** The strongest single tell is a cluster of these words appearing together and often. Core list: additionally (opening a sentence), align with, boasts, bolstered, crucial, deep dive, delve, emphasizing, enduring, enhance, fostering, garner, highlight (verb), interplay, intricate, key (adjective), landscape (abstract), meticulous, pivotal, robust, showcase, tapestry, testament, underscore (verb), valuable, vibrant. Which words dominate shifts by model generation; see the catalog. Do instead: rewrite the sentence around a concrete claim. Do not just look up a synonym.

**Avoiding "is" and "are".** "Serves as", "stands as", "functions as", "represents", "marks", "boasts", "features", "offers", "refers to" replace plain copulas and "has". Do instead: "The gallery is the association's exhibition space. It has four rooms."

**Negative parallelism.** "Not only X but also Y", "It's not just X, it's Y", "It's not X, it's Y", "no X, no Y, just Z", and the reversed "Y rather than X." It simulates correcting a misconception nobody held. Do instead: state the positive claim once. Use a contrast only when someone really holds the opposite view and you can say who.

**Rule of three.** "Adjective, adjective, and adjective", "short phrase, short phrase, and short phrase", used to make thin analysis feel complete. Do instead: use as many items as the facts have, often one or two.

**Elegant variation.** Rotating labels for the same thing ("the artist", "the visionary", "the painter", "the master") to avoid repeating a word. Do instead: repeat the name or use "he/she/they".

**Titles treated as proper nouns.** A lead that defines the page title as a thing ("Catchment area (health) refers to..."). Do instead: open with the subject itself, directly.

**Human syntax to keep.** Humans use simple "is/has" phrases ("there is a", "it has a"), plain verbs ("wrote", "moved", "used", "tried", "died" rather than "authored", "relocated", "utilized", "attempted", "passed away"), definitive statements when true ("was the first", "is the only"), modest hedges and intensifiers ("very", "perhaps", "tends to"), and plain connectives ("in order to", "as a result of", "the fact that"). Stiff euphemistic substitutes are the tell. Do not scrub these natural phrasings out.

### 3. Style and formatting

- **No title heading** that repeats the topic at the top of a piece unless the format needs one.
- **Sentence case** for headings ("Impact of technology", not "Impact of Technology and Digitalization"). Do not leave a heading that contains only other headings, do not skip heading levels, and do not use level-1 headings inside a document body.
- **Bold sparingly.** Mechanical bolding of key phrases is a tell. Reserve it for what the reader must not miss, and use it rarely.
- **No inline-header lists.** Bullets that each start with a bold label and a colon ("**Flavor**: rich and bold") should become prose, or plain bullets without bold labels if a list is truly needed.
- **Em dashes: avoid them.** Use a comma, colon, period, or parentheses. The guide notes that AI em dashes are often formulaic "punched up" contrasts, and a July 2026 study it cites found Claude still used them more than professional writers do. If one is truly the best mark, one per piece is plenty.
- **No emoji** as bullets or heading decoration, except where the platform and the user's own style genuinely call for them.
- **Tables only for real tabular data.** Not for a two-row comparison that reads fine as a sentence.
- **Consistent straight quotes** (" and ') in plain text and code contexts. Curly quotes are common in typeset documents, but mixing curly and straight is a tell. Keep one style.
- **No horizontal rules between every section**, and no Markdown syntax in a destination that will not render it (plain email, wikitext, SMS).

### 4. Chatbot residue

Remove anything addressed to the user that ended up inside the deliverable: "Certainly!", "Of course!", "Great question", "You're absolutely right", "I hope this helps", "Let me know if...", "Would you like me to...", "Here is a...", "As an AI language model...", "I'm sorry, but...". Also remove:

- **Didactic disclaimers:** "It's important to note", "it is crucial to remember", "worth noting", "may vary". If a caveat matters, state the specific caveat.
- **Section summaries:** "In summary", "In conclusion", "Overall" followed by a restatement.
- **Knowledge-cutoff and source-availability disclaimers:** "As of my last update", "specific details are limited", "not widely documented", "based on available information", "maintains a low profile", "keeps personal details private", "should be treated as X rather than Y." These are often speculation. Say what is known and name what is not, specifically ("I could not find his birth year in the sources provided").
- **Placeholders:** "[Name]", "[Insert company]", "(Add your URL here)", "2025-xx-xx". Fill them with real details or list them in the note.
- **Abrupt cut-offs** where generation stopped mid-thought.

### 5. Citations, links, and leaked markup

- **Never fabricate sources.** Invented journal articles, DOIs that resolve to unrelated papers, ISBNs that fail the checksum, real books cited without page numbers, and links that never existed are strong signs. Cite only what you can verify. Otherwise state the claim without a citation, or flag it.
- **Book citations need page numbers** (or a URL to the text) to be checkable.
- **Strip tool artifacts** before delivering: `utm_source=chatgpt.com` or `utm_source=openai` (and copilot or grok equivalents) in URLs; `oaicite`, `contentReference`, `turn0search0`, `attributableIndex`; Gemini's `[cite: 1]` and `[span_1](start_span)`; Grok's `grok_card`; DeepSeek's `【85†L261-269】`; Perplexity's `[attached_file:1]`, `[web:1]`; `:::writing{...}` blocks. The scanner flags these.
- **Do not leave unused or undefined references** in documents that use reference lists.

### 6. Content bias

The guide notes that frontier models show a pro-authoritarian lean on some political prompts, because training data includes state media. On politically sensitive topics, check claims against independent sources rather than repeating a fluent, official-sounding framing as neutral fact.

## Quick reference: what not to do when fixing

- Do not swap a flagged word for a near-synonym and call it done.
- Do not add fake personal stories, quotes, or numbers.
- Do not strip every transition word, formal word, or hedge. Several are normal human usage.
- Do not make the text worse (choppy, sloppy, or inconsistent) to look human.
- Do not leave bracketed placeholders in the final text without telling the user.
