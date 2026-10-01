# Before and after examples

Each pair shows the facts the writer actually had, the AI-pattern version, and the fix. Notice that the fix comes from the facts, not from synonyms. When no facts exist, the right move is to cut or ask, not to invent (see example 7).

## 1. Inflated significance with a trailing "-ing" phrase

Facts available: The Statistical Institute of Catalonia was established in 1989.

Before:
> The Statistical Institute of Catalonia was established in 1989, marking a pivotal moment in the evolution of regional statistics and underscoring Catalonia's commitment to data-driven governance.

After:
> The Statistical Institute of Catalonia was established in 1989.

Note to user: if you know what the institute replaced or what it publishes, one sentence on that would add real value.

What changed: the date was the only fact. Everything after the comma was significance talk with nothing behind it.

## 2. Negative parallelism, promotional tone, rule of three

Facts available: family-run, opened in 2015, menu changes weekly, fish bought from local boats.

Before:
> The restaurant is not just a place to eat, it's a vibrant cultural experience that offers fresh ingredients, warm hospitality, and unforgettable flavors.

After:
> The family-run restaurant opened in 2015. The menu changes weekly, and the fish comes from local boats.

What changed: three empty adjectives became two checkable facts.

## 3. Avoided "is", marketing verbs

Facts available: the gallery belongs to the association; it has four rooms; it shows contemporary art.

Before:
> The gallery serves as the association's exhibition space and features four separate spaces, boasting a vibrant program of contemporary art.

After:
> The gallery is the association's exhibition space. It has four rooms and shows contemporary art.

## 4. Vague attribution and the challenges formula

Facts available: the state auditor's 2024 report found 12% of grants went unspent in 2023.

Before:
> Experts argue that the program has had a significant impact. Despite its successes, it faces several challenges, but with continued efforts it is well positioned for the future.

After:
> The state auditor's 2024 report found that 12% of grants went unspent in 2023.

What changed: "experts" became a named source with a number, and the formulaic ending was dropped.

## 5. Chatbot frame, title heading, emoji, bold-label bullets, em dash, summary

Before:
> Certainly! Here's a short guide to onboarding.
>
> # Onboarding Best Practices 🚀
>
> **Clarity**: Set clear expectations.
> **Communication**: Keep the lines open.
> **Consistency**: Check in regularly.
>
> In conclusion — great onboarding is not just about paperwork, it's about people. I hope this helps!

After:
> In the first week, give a new hire a written list of what they own and who to ask about what. Then check in on the same weekday every week for the first month, even if it is only ten minutes. Most confusion comes from unwritten expectations, and a regular slot gives people a place to raise it.

What changed: the three vague labels turned into two concrete actions, the frame and the conclusion were removed, and the format became plain prose.

## 6. A cover-letter opener

Facts available (from the user): three years at a logistics firm, built SQL reports, one report cut weekly reporting from two days to two hours.

Before:
> I hope this email finds you well. I am writing to express my sincere interest in the Data Analyst position, as I believe my diverse skill set and passion for leveraging data would make me a valuable addition to your esteemed team.

After:
> I'm applying for the Data Analyst role. For the past three years I've built SQL reports at a logistics firm, and one of them cut our weekly reporting from two days to two hours.

## 7. When there are no facts to build on

Request: "Write a paragraph about our company's commitment to sustainability." The user gave no details.

Do not write: "At the heart of our mission lies a deep commitment to sustainability, fostering a greener future through innovative, eco-friendly practices."

Do instead: ask for two or three real details (what they actually do: energy source, packaging change, a target with a date, a certification), then write from those. If the user wants a draft anyway, write a short one that states only what is known, and say in the note which claims need their real numbers.

## 8. Heading and list cleanup

Facts available (from the user): after the 2022 move to online filing, average processing time fell from 14 days to 3 days, and applicants outside the capital no longer have to travel to submit.

Before:
```
## Impact of Technology and Digitalization
- **Speed**: Faster processing.
- **Access**: Wider reach.
- **Cost**: Lower expenses.
```

After:
```
## Impact of online filing
Since the 2022 move to online filing, average processing time has fallen from 14 days to 3. Applicants outside the capital no longer have to travel to submit.
```

What changed: the heading is in sentence case and says what the section covers, the three labels became the two facts the user actually had, and the unsupported "cost" bullet was dropped because nothing backed it up.
