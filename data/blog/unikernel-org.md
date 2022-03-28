---
updated: 2015-12-17
authors:
- name: Amir Chaudhry
  uri: http://amirchaudhry.com
  email: amirmc@gmail.com
subject: Unikernel.org
permalink: unikernel-org
---

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
on board, there's a new community website at **[unikernel.org][]**!

The [unikernel.org][] community site aims to collate information about the
various projects and provide a focal point for early adopters to understand
more about the technology and become involved in the projects themselves.

Over time, it will also become a gathering place for common infrastructure to
form and be shared across projects.  Early examples of this include the
scripts for booting on Amazon EC2, which began with MirageOS contributors but
were used and improved by [Rump Kernel][] contributors.  You can follow the
email threads where the script was [first proposed][ec2-script] and ultimately
provided [EC2 support for Rumprun][ec2-rumprun]. Continuing to work together
to make such advances will ease the process of bringing in new users and
contributors across all the projects.

Please do visit the site and contribute stories about how you're using and
improving unikernels!

*Edit: discuss this post on [devel.unikernel.org][discuss]*

[discuss]: https://devel.unikernel.org/t/why-we-need-unikernel-org/18/1

*Thanks to [Anil][], [Jeremy][] and [Mindy][] for
comments on an earlier draft.*

[unikernel.org]: http://unikernel.org
[Rump Kernel]: http://rumpkernel.org
[ec2-script]: https://www.freelists.org/post/rumpkernel-users/EC2-launch-script-feedback-valued
[ec2-rumprun]: https://www.freelists.org/post/rumpkernel-users/Amazon-EC2-support-now-in-Rumprun

[Jeremy]: https://github.com/yallop
[Mindy]: http://somerandomidiot.com
[Anil]: http://anil.recoil.org

