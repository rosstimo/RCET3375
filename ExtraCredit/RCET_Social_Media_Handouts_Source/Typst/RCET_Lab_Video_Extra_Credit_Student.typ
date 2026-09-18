#set page(paper: "us-letter", margin: (x: 0.55in, y: 0.48in))
#let body-size = 9.3pt
#set text(font: "Liberation Sans", size: body-size, fill: rgb("252525"))
#set par(leading: 0.55em)
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
  #v(2pt)
]
#let pill(body) = box(fill: light, radius: 2pt, inset: (x: 4pt, y: 2pt))[
  #body
]

#block(fill: dark, inset: 9pt, width: 100%)[
  #text(size: 19pt, weight: "bold", fill: white)[RCET Lab Video Extra Credit]
  #linebreak()
  #text(size: 9pt, fill: rgb("D8D8D8"))[Show people what you are actually doing in lab. Record, post, tag, and get back to work.]
]

#v(5pt)
#block(stroke: 1.1pt + orange, radius: 3pt, inset: 7pt, width: 100%)[
  *Earn +1% on this week's lab grade for each qualifying social-media post, up to +5% total.*
  #linebreak()
  #text(size: 8.8pt)[You can use *one video on five platforms*, *five different videos on one platform*, or *any combination in between*. The same exact video posted more than once on the same platform counts only once.]
]

#rule-title[What to do]
+ Record a short video while you are already working in RCET lab.
+ Briefly say what you are working on or what the equipment/program/circuit is doing.
+ Upload it. *No editing, music, graphics, or special effects are required.*
+ Add the appropriate mentions and the standard hashtags below.

*Examples:* "We're programming a PIC microcontroller and trying to get this display working."  "We're using the oscilloscope to troubleshoot this circuit."

#rule-title[Standard hashtags]
#pill[\#idahostateu] #h(4pt) #pill[\#idahostatetech] #h(4pt) #pill[\#robotics]

#text(size: 8.6pt)[You may add a topic-specific hashtag if it fits, such as \#electronics, \#programming, \#microcontrollers, \#embeddedsystems, or \#cybersecurity.]

#rule-title[Who to mention or tag]
#table(
  columns: (0.85in, 1fr),
  [*Instagram*], [`@isu_robotics`  `@isucollegeoftechnology`  `@idahostateu`  |  `#idahostateu #idahostatetech #robotics`],
  [*Facebook*], [Tag _Idaho State University Robotics Program_, _Idaho State University College of Technology_, and _Idaho State University_. Hashtags: `#idahostateu #idahostatetech #robotics`],
  [*X*], [Tag _ISU College Of Technology_ and _Idaho State University_. Hashtags: `#idahostateu #idahostatetech #robotics`],
  [*YouTube*], [Tag/mention _Idaho State University College of Technology_ and _Idaho State University_. Hashtags: `#idahostateu #idahostatetech #robotics`],
  [*Other*], [Hashtags, when supported: `#idahostateu #idahostatetech #robotics`. No additional institutional account is listed unless verified by the instructor.],
)

*Good platforms:* Instagram, Facebook, X, YouTube Shorts, or another instructor-approved platform you already use. You do *not* need to create a new social-media account.

#rule-title[What do \@mentions and \#hashtags do?]
*\@mention/tag:* points to a specific account or page. It helps RCET, the College of Technology, or ISU find your post and potentially share it.

*\#hashtag:* labels the topic. People can click or search a hashtag to find related public posts.

#block(fill: light, radius: 3pt, inset: 7pt, width: 100%)[
  *Prefer not to use social media?* If you have difficulty using social media or prefer not to use it, meet with your instructor. You can discuss another way to earn equivalent extra credit.
]

#v(1fr)
#line(length: 100%, stroke: 0.5pt + rgb("DDDDDD"))
#text(size: 7.5pt, fill: gray)[Robotics and Communication Systems Engineering Technology • Idaho State University #h(1fr) Fall 2026]
