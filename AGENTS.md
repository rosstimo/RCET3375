# Repository scope

This is a student-facing course-material repository.

During analysis, treat all course content here as read-only unless the user
explicitly requests curriculum edits. When constructing a pilot, copy canonical
course sources only and exclude this repository's generated Graphify output,
caches, reports, exports, and packaged duplicates.

<!-- BEGIN MANAGED: curriculum-graphify-workflow -->
# Curriculum Graphify workflow

Use the installed Graphify skill for curriculum knowledge-graph work. Treat a
curriculum corpus as instructional content and progression, not as software
architecture.

## Query existing graphs first

For an existing graph, use `graphify query`, `graphify path`, and
`graphify explain` before broad source browsing. Use
`graphify-out/wiki/index.md` for broad navigation when present, and read
`graphify-out/GRAPH_REPORT.md` for an overall audit or when scoped graph queries
are insufficient. Dirty generated Graphify files are not a reason to skip graph
queries.

## Standard clean workflow

- Build a new, source-only pilot outside the curriculum source repository.
  Preserve any comparison baseline outside every Graphify source root.
- Include canonical source documents only. Exclude `graphify-out/`, semantic
  caches, extraction fragments, reports, wiki output, packaged review copies,
  exported bundles, baselines, and other generated or duplicate artifacts.
- Record a source manifest with repository identity, revision, relative source
  path, destination path, and content hash so the pilot is reproducible and
  duplicate evidence is detectable.
- Run the standard deep curriculum workflow. Generate a wiki when the user asks
  for a curriculum knowledge base. Do not generate a visualization unless the
  user explicitly requests one.
- A successful standard run must be reproducible from sources. Never manually
  edit or replace semantic cache entries to make validation pass; correct a
  generic extraction or validation defect and rerun the required stages.
- Keep curriculum and student-facing source files unchanged during analysis
  unless the user explicitly requests content edits.

## Evidence authority and timing tables

- Determine a document's authority from its stated purpose and content, not
  merely its filename, directory, or repository.
- Keep proposed plans, current release schedules, historical teaching evidence,
  and other schedule authorities separate. Preserve competing schedules as
  parallel evidence rather than merging them or calling them historical
  contradictions.
- Extract every meaningful row from curriculum timing, pacing, release,
  due-date, and assignment-alignment tables.
- Treat assignment numbers as ordered identifiers, never as week numbers.
  Preserve multiple assignments per period and assignments spanning multiple
  weeks.
- Attach source-file and row-level provenance to every structured timing
  relationship when the source format supports it.
- Never infer a week from an assignment identifier or historical date. Convert
  a date to a week only when the same source explicitly provides that mapping.
- Preserve course identity and authority identity in node and relationship
  identifiers. Do not merge similarly named assignments, weeks, or schedules
  without source evidence.

## Fail-closed validation

Before accepting a curriculum graph, require all applicable checks to pass:

- complete, unique source-manifest coverage with no packaged duplicate evidence;
- complete timing-table row and assignment-timing coverage;
- no missing, invented, or untraceable timing concepts or relationships;
- separation of proposed, current-release, historical, and other schedule
  authorities;
- source-file and row-level provenance for extracted timing evidence;
- no dangling or missing endpoints, duplicate edges, self-loops, or collapsed
  edges; and
- wiki counts reported consistently as total Markdown files, index files, and
  articles excluding indexes.

Stop and report the exact failed gate rather than presenting a partial run as a
validated curriculum analysis. Course-specific corpus sizes, assignment counts,
calendar lengths, graph metrics, and wiki counts are validation evidence, not
reusable workflow requirements.

For ordinary code-only maintenance, `graphify update .` may refresh structural
changes. Do not use that AST-oriented update as a substitute for the standard
curriculum workflow after curriculum content or schedule evidence changes.
<!-- END MANAGED: curriculum-graphify-workflow -->
