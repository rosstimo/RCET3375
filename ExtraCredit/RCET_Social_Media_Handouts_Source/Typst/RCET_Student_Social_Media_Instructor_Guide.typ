#set page(paper: "us-letter", margin: 0.62in)
#let body-size = 9.2pt
#set text(font: "Liberation Sans", size: body-size, fill: rgb("252525"))
#set par(leading: 0.58em)
// Keep literal account names and hashtags at the surrounding text's size.
#show raw: it => text(font: "Liberation Sans", size: body-size, it.text)
#set table(inset: (x: 6pt, y: 4pt), stroke: 0.4pt + rgb("D5D5D5"))

#let orange = rgb("F47B20")
#let dark = rgb("252525")
#let light = rgb("F7F7F7")
#let gray = rgb("666666")
#let rule-title(body) = [
  #v(3pt)
  #text(size: 13pt, weight: "bold", fill: dark)[#body]
  #v(1pt)
  #line(length: 100%, stroke: 1.1pt + orange)
  #v(1pt)
]
#let pill(body) = box(fill: light, radius: 2pt, inset: (x: 4pt, y: 2pt))[
  #body
]

#block(fill: dark, inset: 9pt, width: 100%)[
  #text(size: 19pt, weight: "bold", fill: white)[RCET Student Social Media]
  #linebreak()
  #text(size: 9pt, fill: rgb("D8D8D8"))[Instructor Guide • Lab-video extra credit for recruitment and program visibility]
]

#rule-title[Purpose]
The goal is to increase visibility of RCET by showing authentic student work. This should *not become another assignment*. Students should spend only the time needed to record something they are already doing and post it. Do not grade production quality.

#rule-title[Extra-credit rule]
#block(stroke: 1.1pt + orange, radius: 3pt, inset: 7pt, width: 100%)[
  Award *+1% on the current week's lab grade per qualifying social-media post*, up to *+5% total*. Credit is based on qualifying posts, not unique videos or unique platforms.
]

A student can earn the full 5% by posting one video on five platforms, five different videos on one platform, or any combination. For example: two Instagram videos + one Facebook post + one X post + one YouTube Short = 5%. The same exact video reposted repeatedly on the same platform counts only once.

#rule-title[Official accounts and pages]
The account names below were supplied by the College of Technology Digital and Social Media Manager.

#table(
  columns: (1.05in, 1.05in, 1fr),
  [*Organization*], [*Platform*], [*Account / page*],
  [Robotics], [Instagram], [`@isu_robotics`],
  [Robotics], [Facebook], [Idaho State University Robotics Program],
  [College of Tech], [Instagram], [`@isucollegeoftechnology`],
  [College of Tech], [Facebook], [Idaho State University College of Technology],
  [College of Tech], [LinkedIn], [Idaho State University College of Technology],
  [College of Tech], [X], [ISU College Of Technology],
  [College of Tech], [YouTube], [Idaho State University College of Technology],
  [University], [Instagram], [`@idahostateu`],
  [University], [Facebook], [Idaho State University],
  [University], [LinkedIn], [Idaho State University],
  [University], [X], [Idaho State University],
  [University], [YouTube], [Idaho State University],
)

#rule-title[Standard hashtags]
College of Technology marketing recommends #pill[\#idahostateu] #h(3pt) #pill[\#idahostatetech]. For RCET content, add #pill[\#robotics]. Students may optionally add one relevant topic hashtag such as \#electronics, \#programming, \#microcontrollers, \#embeddedsystems, or \#cybersecurity.

#rule-title[Mentions vs. hashtags]
*\@mention/tag:* identifies a particular account or page. Depending on the platform, it can notify the account and makes it easier for RCET, College of Technology, or ISU staff to find, interact with, or reshare the post.

*\#hashtag:* labels a topic and connects the post with other public posts using the same hashtag.

#rule-title[Platform guidance]
#table(
  columns: (0.82in, 1.5fr, 1fr),
  [*Platform*], [*Mentions / tags*], [*Hashtags*],
  [Instagram], [`@isu_robotics`, `@isucollegeoftechnology`, `@idahostateu`], [`#idahostateu #idahostatetech #robotics`],
  [Facebook], [Tag Robotics Program, College of Technology, and Idaho State University pages], [`#idahostateu #idahostatetech #robotics`],
  [X], [Tag ISU College Of Technology and Idaho State University], [`#idahostateu #idahostatetech #robotics`],
  [YouTube], [Mention Idaho State University College of Technology and Idaho State University], [`#idahostateu #idahostatetech #robotics`],
  [LinkedIn], [Tag Idaho State University College of Technology and Idaho State University pages], [`#idahostateu #idahostatetech #robotics`],
)

#rule-title[Platform priorities]
*Instagram* is the strongest recruitment target and should be the first recommendation. *Facebook* is useful for alumni, parents, families, and the broader community. *X* and *YouTube Shorts* provide additional distribution. LinkedIn or another appropriate platform can count when a student already uses it. Students should not be required to create an account solely for extra credit.

#rule-title[Students who do not want to use social media]
Students may have privacy concerns, personal objections, accessibility issues, account restrictions, or simply not use social media. Offer an equivalent recruiting/outreach option rather than making personal social-media use a requirement.

Possible alternatives include:
- participating in an official ISU or College of Technology marketing video;
- participating in a recruiting event, open house, tour, or program demonstration;
- assisting with an RCET recruiting or outreach activity; or
- another instructor-approved activity that meaningfully contributes to recruitment.

#rule-title[TikTok]
College of Technology marketing does not recommend TikTok because ISU is not supposed to maintain a TikTok presence. Do not require or specifically encourage TikTok as part of this activity.

#rule-title[Instagram Collab]
Instagram supports a Collab feature. A student can invite another account as a collaborator; if accepted, the post can appear on both profiles. This could allow selected student posts to appear directly on `@isu_robotics` or a College account. Coordinate with College of Technology marketing before instructing students to send Collab invitations broadly.

#rule-title[What qualifies]
A qualifying post should show something the student is actually doing in RCET, briefly explain what is happening, be appropriate for public viewing, include the standard hashtags, and include relevant program/college/university mentions when the platform supports them.

*Do not grade:* editing, camera quality, music, graphics, or presentation polish. The desired result is authentic student activity, not advertising produced by students.

#v(1fr)
#line(length: 100%, stroke: 0.5pt + rgb("DDDDDD"))
#text(size: 7.5pt, fill: gray)[Robotics and Communication Systems Engineering Technology • Idaho State University #h(1fr) Fall 2026]
