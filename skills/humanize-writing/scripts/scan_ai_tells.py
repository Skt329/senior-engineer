#!/usr/bin/env python3
"""Scan text for the writing patterns catalogued in Wikipedia's "Signs of AI writing".

Usage:
    python scan_ai_tells.py draft.txt
    cat draft.txt | python scan_ai_tells.py
    python scan_ai_tells.py draft.txt --json
    python scan_ai_tells.py draft.txt --max-examples 10

This is a map, not a verdict. Humans trip many of these patterns, and the scanner
cannot see semantic problems (vague claims, empty analysis, elegant variation).
Use it to find places to look, then fix the underlying vagueness, not just the words.
"""
import argparse
import json
import re
import sys
from collections import OrderedDict

I = re.IGNORECASE


def rx(pattern, flags=I):
    return re.compile(pattern, flags)


# (category, description, compiled pattern)
RULES = [
    ("ai_vocabulary", "AI vocabulary cluster", rx(
        r"\b(?:delv(?:e|es|ed|ing)|tapestry|testament|pivotal|crucial|"
        r"intricate|intricacies|interplay|meticulous(?:ly)?|vibrant|"
        r"garner(?:s|ed|ing)?|bolster(?:s|ed|ing)?|underscor(?:e|es|ed|ing)|"
        r"showcas(?:e|es|ed|ing)|foster(?:s|ed|ing)?|enduring|"
        r"enhanc(?:e|es|ed|ing)|highlight(?:s|ed|ing)?|emphasiz(?:e|es|ed|ing)|"
        r"align(?:s|ed|ing)? with|deep dive|robust|valuable|"
        r"(?:evolving|digital|changing|broader|cultural|competitive) landscape|landscape of)\b")),
    ("ai_vocabulary", "Sentence-opening 'Additionally,'", rx(r"(?:^|[.!?]\s+)Additionally,")),
    ("significance", "Inflated significance / legacy phrasing", rx(
        r"\b(?:(?:stands|serves) as (?:a |an |the )?(?:testament|reminder|symbol|beacon)|"
        r"is a (?:testament|reminder) to|a testament to|"
        r"plays? an? (?:crucial|pivotal|vital|significant|key|important) role|"
        r"(?:underscor|highlight)(?:es|ing)? (?:its|the|their) (?:importance|significance)|"
        r"reflects? (?:the )?broader|symboli[sz](?:es|ing) (?:its|the|their)|"
        r"setting the stage for|marks? a (?:shift|turning point)|key turning point|"
        r"focal point|indelible mark|deeply rooted|lasting (?:legacy|impact)|"
        r"enduring legacy|rich (?:cultural )?(?:heritage|history|tapestry))\b")),
    ("notability", "Canned notability / media-coverage claims", rx(
        r"\b(?:independent coverage|(?:local|regional|national|international) "
        r"(?:media|news) outlets|trade publications|(?:cited|featured|profiled) in|"
        r"leading expert|active social media presence|maintains? an? (?:\w+ ){0,2}social media presence)\b")),
    ("superficial_ing", "Tacked-on '-ing' commentary", rx(
        r",\s+(?:highlighting|underscoring|emphasi[sz]ing|ensuring|reflecting|"
        r"symboli[sz]ing|contributing to|cultivating|fostering|encompassing|"
        r"enhancing|showcasing|demonstrating|illustrating)\b")),
    ("superficial_ing", "'valuable insights' / 'resonate with'", rx(r"\b(?:valuable insights?|resonates? with)\b")),
    ("promotional", "Promotional / travel-guide wording", rx(
        r"\b(?:boasts? an?|nestled|in the heart of|groundbreaking|renowned|"
        r"diverse array|commitment to|natural beauty|world-class|state-of-the-art|"
        r"cutting-edge|unparalleled|exemplif(?:y|ies|ied)|profound)\b")),
    ("association", "Vague connection / association", rx(
        r"\b(?:in connection (?:with|to)|connected (?:with|to)|in association with|associated with)\b")),
    ("weasel", "Vague attribution", rx(
        r"\b(?:industry reports?|observers (?:have|note|say)|experts (?:argue|say|believe|note)|"
        r"some critics (?:argue|say|note)|critics (?:argue|say)|scholars (?:argue|note|believe)|"
        r"several (?:sources|publications|studies)|it is widely (?:believed|regarded|considered))\b")),
    ("challenges_formula", "Formulaic challenges / outlook ending", rx(
        r"\b(?:despite (?:its|these|the) [^.]{0,80}(?:faces?|continues to face) (?:several |some |a number of )?challenges|"
        r"despite these challenges|future outlook|future prospects|challenges and (?:legacy|opportunities))\b")),
    ("copula_avoidance", "Avoids plain 'is/are/has'", rx(
        r"\b(?:(?:serves|stands|functions|operates) as (?:a|an|the)|represents (?:a|an|the)|"
        r"boasts|(?:features|offers|maintains) (?:a|an|the)|refers to|marks (?:a|the))\b")),
    ("negative_parallelism", "Negative parallelism ('not just X, but Y')", rx(
        r"\bnot (?:only|just|merely|simply) [^.;!?]{0,100}?(?:but|,\s*it'?s|,\s*it is)\b")),
    ("negative_parallelism", "'It's not X, it's Y' / 'no X, no Y, just Z'", rx(
        r"\b(?:it'?s|it is|this is|that'?s|this isn'?t|it isn'?t) not [^.;!?]{0,80}[,;:]\s*(?:it'?s|it is|but|rather)\b|"
        r"\bno [^.,;]{1,30}, no [^.,;]{1,30}, (?:just|only)\b")),
    ("didactic", "Didactic disclaimers", rx(
        r"\b(?:it(?:'s| is) (?:important|crucial|critical|worth) (?:to )?(?:note|remember|consider|noting)|"
        r"worth noting|it should be noted)\b")),
    ("conclusion", "Section summary / conclusion opener", rx(
        r"(?:^|[.!?]\s+|\n)(?:In (?:summary|conclusion)|To sum up|Overall|In short),")),
    ("chatbot_residue", "Chatbot residue", rx(
        r"\b(?:certainly!|of course!|absolutely!|great question|you'?re absolutely right|"
        r"i hope (?:this|that) helps|let me know if|is there anything else|"
        r"would you like (?:me )?to|here(?:'s| is) (?:a|an|the|your) |as an ai(?: language model)?|"
        r"as a large language model|i(?:'m| am) sorry,? but|i (?:cannot|can'?t) (?:offer|provide))")),
    ("cutoff_disclaimer", "Knowledge-cutoff / source-availability disclaimer", rx(
        r"\b(?:as of my (?:last )?(?:knowledge|training)|up to my last|knowledge cutoff|"
        r"while specific details (?:are|remain) (?:limited|scarce)|"
        r"(?:is|are) not (?:widely|publicly) (?:available|documented|disclosed)|"
        r"maintains? a low profile|keeps? (?:his|her|their) (?:personal )?(?:life|details) private|"
        r"based on (?:the )?available (?:information|sources)|"
        r"should be treated as [^.]{0,60} rather than)\b")),
    ("placeholder", "Placeholder / unfilled template text", rx(
        r"\[(?:your |insert |add |entertainer'?s |company |client |recipient'?s )?(?:name|company|date|url|link|title|details?)[^\]]{0,40}\]|"
        r"\((?:add|insert|if available)[^)]{0,50}\)|\b20\d\d-(?:xx|XX)-(?:xx|XX)\b|\bXX/XX\b")),
    ("leaked_markup", "Leaked tool markup / tracking parameters", rx(
        r"oaicite|contentReference|oai_citation|turn\d+(?:search|image|news|file)\d+|"
        r"attributableIndex|utm_source=(?:openai|chatgpt\.com|copilot\.com)|referrer=grok\.com|"
        r"\[cite:\s*[\d,\s]+\]|\[span_\d+\]|\((?:start|end)_span\)|grok_card|"
        r"grok_render_citation_card_json|【\d+†[^】]*】|\[attached_file:\d+\]|\[web:\d+\]|"
        r"ppl-ai-file-upload|:::writing")),
]

EMOJI = re.compile("[\U0001F300-\U0001FAFF\u2600-\u27BF\u2B50\u2705\u274C\u2728]")
PUA = re.compile("[\ue000-\uf8ff]")
EM_DASH = re.compile(r"—|\s--\s|\s–\s")
CURLY = re.compile("[\u201c\u201d\u2018\u2019]")
STRAIGHT = re.compile(r"[\"']")
BOLD = re.compile(r"\*\*[^*\n]+\*\*|__[^_\n]+__")
INLINE_HEADER = re.compile(r"^\s*(?:[-*\u2022]|\d+[.)])\s+(?:\*\*|__)[^*_\n]+(?:\*\*|__)\s*:?", re.M)
MD_HEADING = re.compile(r"^(#{1,6})\s+(.+?)\s*$", re.M)
HRULE = re.compile(r"^\s*(?:-{3,}|\*{3,}|_{3,})\s*$", re.M)
TABLE_SEP = re.compile(r"^\s*\|?\s*:?-{3,}:?\s*(?:\|\s*:?-{3,}:?\s*)+\|?\s*$", re.M)
TRIPLE = re.compile(r"\b[\w-]+(?:\s[\w-]+)?, [\w-]+(?:\s[\w-]+)?,? and (?!(?:i|we|he|she|they|it|you|there|then|so)\b)[\w-]+(?:\s[\w-]+)?(?=[\s.,;:!?)]|$)", I)
SMALL = {"a", "an", "and", "as", "at", "but", "by", "for", "from", "in", "into", "nor",
         "of", "on", "or", "the", "to", "with", "vs", "via"}


def title_case_heading(text):
    words = re.findall(r"[A-Za-z][A-Za-z'-]*", text)
    main = [w for w in words if w.lower() not in SMALL]
    if len(main) < 3:
        return False
    caps = sum(1 for w in main if w[0].isupper())
    return caps / len(main) >= 0.8


def line_of(text, pos):
    return text.count("\n", 0, pos) + 1


def snippet(text, m, width=50):
    """Context around a match, clipped to its own line, with the match marked «like this»."""
    ls = text.rfind("\n", 0, m.start()) + 1
    le = text.find("\n", m.end())
    le = len(text) if le == -1 else le
    a = max(ls, m.start() - width)
    b = min(le, m.end() + width)
    out = text[a:m.start()] + "\u00ab" + text[m.start():m.end()] + "\u00bb" + text[m.end():b]
    return ("..." if a > ls else "") + out.strip() + ("..." if b < le else "")


def scan(text):
    findings = OrderedDict()

    def add(cat, desc, line, snip):
        findings.setdefault(cat, []).append({"line": line, "what": desc, "text": snip})

    for cat, desc, pat in RULES:
        for m in pat.finditer(text):
            add(cat, desc, line_of(text, m.start()), snippet(text, m))

    for m in EM_DASH.finditer(text):
        add("em_dash", "Em dash (or spaced dash) used as punctuation", line_of(text, m.start()), snippet(text, m, 40))
    for m in EMOJI.finditer(text):
        add("emoji", "Emoji", line_of(text, m.start()), snippet(text, m, 30))
    for m in PUA.finditer(text):
        add("leaked_markup", "Private-use Unicode character (often citation markup)", line_of(text, m.start()), repr(m.group()))
    for m in BOLD.finditer(text):
        add("bold", "Bold span", line_of(text, m.start()), snippet(text, m, 20))
    for m in INLINE_HEADER.finditer(text):
        add("inline_header_list", "Bullet with bold inline header", line_of(text, m.start()), snippet(text, m, 20))
    for m in MD_HEADING.finditer(text):
        level, title = len(m.group(1)), m.group(2)
        if level == 1:
            add("headings", "Level-1 heading inside body", line_of(text, m.start()), title)
        if title_case_heading(title):
            add("headings", "Title Case heading (use sentence case)", line_of(text, m.start()), title)
    for m in HRULE.finditer(text):
        add("thematic_break", "Horizontal rule between sections", line_of(text, m.start()), m.group().strip())
    for m in TABLE_SEP.finditer(text):
        add("table", "Markdown table (check it is truly tabular data)", line_of(text, m.start()), m.group().strip()[:40])
    for m in TRIPLE.finditer(text):
        add("rule_of_three", "Triple list ('A, B, and C')", line_of(text, m.start()), snippet(text, m, 25))

    curly = len(CURLY.findall(text))
    straight = len(STRAIGHT.findall(text))
    if curly and straight:
        findings.setdefault("quotes", []).append({
            "line": 0, "what": "Mixed curly and straight quotes",
            "text": f"{curly} curly vs {straight} straight; pick one style"})
    elif curly:
        findings.setdefault("quotes", []).append({
            "line": 0, "what": "Curly quotes/apostrophes (fine in typeset docs; use straight in plain text)",
            "text": f"{curly} curly characters"})

    # Heading structure: skipped levels
    levels = [len(m.group(1)) for m in MD_HEADING.finditer(text)]
    for prev, cur in zip(levels, levels[1:]):
        if cur > prev + 1:
            findings.setdefault("headings", []).append({
                "line": 0, "what": "Skipped heading level", "text": f"jumped from H{prev} to H{cur}"})
            break
    if levels and levels[0] == 1:
        pass  # already reported per-heading

    return findings


def main():
    try:  # exit quietly when output is piped into `head`, etc.
        import signal
        signal.signal(signal.SIGPIPE, signal.SIG_DFL)
    except (ImportError, AttributeError, ValueError):
        pass
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("path", nargs="?", help="text file to scan (default: stdin)")
    ap.add_argument("--json", action="store_true", help="emit JSON")
    ap.add_argument("--max-examples", type=int, default=5, help="examples shown per category (default 5)")
    args = ap.parse_args()

    text = open(args.path, encoding="utf-8").read() if args.path else sys.stdin.read()
    words = len(re.findall(r"\b[\w'-]+\b", text))
    findings = scan(text)
    total = sum(len(v) for v in findings.values())
    density = (total / words * 1000) if words else 0.0

    if args.json:
        print(json.dumps({"words": words, "total_flags": total,
                          "flags_per_1000_words": round(density, 1),
                          "findings": findings}, ensure_ascii=False, indent=2))
        return

    print(f"Words: {words}   Flags: {total}   Flags per 1,000 words: {density:.1f}")
    print("Treat this as a map of where to look. Humans trigger many of these; "
          "fix the vagueness behind a flag, not just the words.\n")
    if not findings:
        print("No pattern matches. Still read the text for vague claims and generic sentences.")
        return
    for cat, items in findings.items():
        print(f"[{cat}] {len(items)} hit(s)")
        shown = 0
        seen = set()
        for it in items:
            key = (it["what"], it["text"])
            if key in seen:
                continue
            seen.add(key)
            loc = f"line {it['line']}" if it["line"] else "document"
            print(f"  - {loc}: {it['what']}: {it['text']}")
            shown += 1
            if shown >= args.max_examples:
                break
        if len(items) > shown:
            print(f"  ... and {len(items) - shown} more")
        print()


if __name__ == "__main__":
    main()
