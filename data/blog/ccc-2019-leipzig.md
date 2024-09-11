---
updated: 2020-01-08
authors:
- name: Damien Leloup
  uri: https://www.lemonde.fr/signataires/damien-leloup/
  email:
subject: Hackers and climate activists join forces in Leipzig
permalink: ccc-2019-leipzig
---

_By Damien Leloup, special correspondent, Le Monde. Originally [published](https://www.lemonde.fr/pixels/article/2019/12/30/a-leipzig-hackers-et-militants-pour-le-climat-font-front-commun_6024362_4408996.html) by Le Monde on December 30, 2019. English translation by the MirageOS Core Team._

**The Chaos Communication Congress, the world's largest self-managed event dedicated to IT security, hosted its 36th edition this weekend in Germany.**

In front of Leipzig station, around fifty students and high school students are gathered.  It's Sunday, but the local branch of the Fridays for Future movement, which organizes demonstrations on Fridays at the call of activist Greta Thunberg, made an exception to its usual calendar to take advantage of the presence, a few kilometers from there, of the Chaos Communication Congress (CCC).

Organized each year for thirty-six years, this gigantic gathering of hackers and activists - 18,000 participants, dozens of conference talks around the clock - invades the Leipzig convention center for four days, in an atmosphere that is both anarcho-libertarian and very family oriented.  For the first time, the slogan of the 2019 edition is devoted to the environment: “Resource exhaustion”, a reference both to a computer [attack technique](https://en.wikipedia.org/wiki/Resource_exhaustion_attack) and to the preservation of the planet.

_"It makes sense: it's a major issue, and the environmental movement is a highlight of the year, isn't it?"_, notes, hair dyed pink and megaphone in hand, Rune, one of the organizers of the event. _“In any case, we are very happy that the CCC opened its doors to us and supports us."_

The conference program gave pride of place to ecological themes and organizations such as Fridays for Future or Extinction Rebellion. These themes were all features in the main talks.  The audience for the event, marked on the far left, is quite sensitive to environmental issues.  [Fridays for Future's](https://www.fridaysforfuture.org/) review of the year was sold out;  the track where some scientists explained how they build their climate models was full and was not able to host all the attendees.

## Safety of power plants and the right to repair 

But if the CCC has given a lot of space to environmental issues, it has done it in its own way.  In this mecca of cyber-security, we could for example discover long lists of vulnerabilities affecting the on-board systems used to manage the turbines of power plants. _Do not_ panic: _"These flaws do not block a power plant, or cut the power of a city,"_ relativized Radu Motspan, the author of the study.  Some of them have been corrected;  for others, it is up to plant managers to carry out verifications.  The researcher and his associates produced a small turnkey guide to help them: _“No need to hire expensive consultants, you can do everything yourself."_

This “do it yourself” spirit, omnipresent in hacker culture in general and at the CCC in particular, easily lends itself to an environmental translation.  The collective [Runder Tisch Reparatur](https://runder-tisch-reparatur.de/), which campaigns for the adoption at European level of a "right to repair", was thus invited for the first time to the conference.  The philosophy of the movement, which aims above all to reduce the amount of waste produced by obsolescence whether or not it is programmed, is very similar to that of the free software movement, say Eduard and Erik, who run the stand of the association. _"An object that you cannot repair does not really belong to you,"_ they believe, just as the promoters of free software believe that software that you cannot modify yourself deprives you of certain freedoms.

But the main issue, at the heart of many talks during the four days of the CCC, is that of the energy impact of the Internet.  No one in the aisles of the Leipzig congress center plans to reduce their use of the Internet;  but everyone concedes that the network consumes a lot of electricity unnecessarily, or uses too much fossil energy.  _"There are simple things to do to improve the carbon footprint of a site or service,"_ said Chris Adams, environmental activist and member of the Green Web Foundation.  _“If your service uses Amazon Web Service [AWS, a very popular cloud service], you can choose the data center you want to use, for example.  The one assigned to you by default may be in a country that produces little renewable electricity and uses a lot of coal for its power plants… ”_

Existing non-digital systems (like boilers) already have ways to function more efficiently, such as off-peak hours at night, when electricity is both cheaper and more eco-friendly. There are equivalent options for more modern, digital systems, for instance: Chris Adams advocates the use of the [Low Carbon Kubernetes Scheduler](http://ceur-ws.org/Vol-2382/ICT4S2019_paper_28.pdf), an orchestration tool which allows to optimise the power consumption of a server in order to reduce its environmental impact. 

## Safety and minimum consumption, get the best of both worlds

Despite everything, the “greenest” electricity remains that which we do not consume in the first place.  There too, promising solutions exist: [Hannes Mehnert](https://hannes.robur.coop/), a German computer scientist, presented at the opening of the CCC the MirageOS project, an operating system for ultra-minimalist servers, coded in a language renowned for its lightness, and which runs each process in a dedicated virtual machine.  A radical approach - and reserved for connoisseurs - which allows the software to embed only the bare minimum of lines of code in each compiled version. _"Reducing complexity mathematically reduces the number of calculation operations required,"_ explains Mehnert.  Result: _"A carbon footprint that drops drastically, with ten times less computing power used by the processor, and up to twenty-five times less memory used"_, according to his measurements.

Above all, and this is a strong argument at a conference dedicated to computer security, minimalism is also a real advantage in terms of potential vulnerabilities: the more compact the code is, the less it risks containing flaws or errors.  And such systems are also better protected and safer than more conventional systems, as they are not vulnerable to memory-safety issues.

But the collaboration between environmentalists and privacy advocates seemed much broader than just focusing on technical issues. That mix was everywhere: for instance the corridor walls had graffiti concerned with the the excessive consumption of CO2 on the planet close to others highlighting the fact that every human being generates, on average, 1.7 MB of data per second. The posters of the anarchist or anti-fascist movements were also mixed with the flyers of the collective Hackers against [Climate Change](https://hacc.uber.space/Main_Page), which attracted the curious with a joke typical of the place: _"cli / mate crisis is real"_, in reference to Club-Mate, an ubiquitous drink at the event.

This community of views between hackers and climate activists comes as little surprise in Germany, where both movements are very present, and even less in Leipzig, the flagship city of the former GDR where pre-Internet mass surveillance tools from the Stasi were also directed against environmental activists in the 1980s. Some environmental movements feel naturally close to the anarchist spirit of the German hackers of the Chaos Computer Club, which organizes the CCC: a talk by [Extinction Rebellion](https://rebellion.earth/) detailed the security measures they took to ensure their privacy, and how they didn't depend on third-party tools from Facebook, Google or Amazon - responsible, in their eyes, both for mass surveillance and _green washing_.

However, in this atmosphere of global collaboration some questions remained unanswered.  In some specific cases, better IT security can also consume more resources.  A talk dedicated to encrypted messaging thus presented many tools which make it possible to reinforce the confidentiality of exchanges, but also require using more computing power, to encrypt or decrypt messages, or even request the sending of large quantities of data to scramble the origin or volume of a message.  This first CCC under the sign of environmental protection did not really address this contradiction - pending, perhaps, a next edition?

