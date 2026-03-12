---
layout: gallery
title: "GitHub-Style Generated Avatars"
order: 500
category: "Random"
image: "/webp-gallery/github_inspired_randomly_generated_pfps_for_my_first_rails_project.webp"
alt: "Generated Profile Pictures from Greendit"
---

Client side generated profile pictures inspired by GitHub identicons, built for my first fullstack PHP project Greendit.

If a user does not upload an image, a deterministic avatar is generated in the browser from the username using a small canvas routine. The generated image is embedded into the form and submitted like any other upload. The server stores it normally, but does not participate in generation.

The implementation is simple. A seeded value determines color selection and mirrored pixel placement on a small grid. Not much code, but a noticeable improvement in user identity and perceived completeness.
