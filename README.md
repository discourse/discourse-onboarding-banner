# DiscourseOnboardingBanner

DiscourseOnboardingBanner is a plugin to display a banner to help new users orient themselves.

## Installation

Follow [Install a Plugin](https://meta.discourse.org/t/install-a-plugin/19157)
how-to from the official Discourse Meta, using `git clone https://github.com/discourse/discourse-onboarding-banner.git`
as the plugin command.

## Usage

Create a topic in a category that is accessible by everyone. The topic can be
set to 'Unlisted'. Content similar to the following might be a good starting point
for your welcome banner.

**NOTE** Please check the links are valid on your site!

```
# Welcome to {%sitename}. Let's get started!

<div data-theme-onboard>

- [Add your picture](/my/preferences/)
- [Set up your profile](/my/preferences/profile/)
- [Introduce yourself](/t/welcome-to-the-lounge/8)

</div>
```

After creating the topic take note of the topic ID and navigate to:

Admin -> Settings -> Plugins -> DiscourseOnboardingBanner Settings

and enter the topic ID and save. Then enable the plugin and save.

If you have dismissed the banner while testing the plugin and wish to see
it again, run the following in a console (where `[YOUR_USERNAME]` is your
username).

```
User.find_by(username: '[YOUR_USERNAME]').
     user_custom_fields.
     where(name: 'onboarding_banner_dismissed_topic_id').
     destroy_all
```

## Feedback

If you have issues or suggestions for the plugin, please bring them up on
[Discourse Meta](https://meta.discourse.org).
