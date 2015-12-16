Unikernels are specialised single address space machine images that are
constructed by using library operating systems. With MirageOS, we've taken a
clean-slate approach to unikernels with a focus on safety. This involved
writing protocol libraries from the ground up and it also afforded the ability
to use clean, modern APIs.

Other unikernel implementations have made trade-offs different to those made
by MirageOS. Some excel at handling legacy applications by making the most of
existing OS codebases rather than building clean-slate implementations. Some
target a wide array of possible environments, or environments complementary to
those supported by MirageOS currently.
All of these implementations ultimately help developers construct unikernels
that match their specific needs and constraints.

As word about unikernels in general is spreading, more people are trying to
learn about this new approach to programming the cloud and embedded devices.
Since information is spread across multiple sites, it can be tricky to know
where to get an overview and how to get started quickly. So to help people get
on board, there's a new community website [unikernel.org][]!

The [unikernel.org][] community site aims to collate information about the
various projects and provide a focal point for early adopters to understand
more about the technology and become involved in the projects themselves. Over
time, we hope it will become a gathering place to share stories and advances
that the community is making and ease the process of bringing in new
contributors and users for the range of projects.

Please do visit the site and consider contributing stories about how you're
using unikernels!

*Thanks to [Jeremy][] and [Mindy][] for comments on an earlier draft*

[unikernel.org]: http://unikernel.org
[Jeremy]: https://github.com/yallop
[Mindy]: http://somerandomidiot.com
