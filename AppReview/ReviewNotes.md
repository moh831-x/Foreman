# Foreman — App Review Information

Two parts:

- **Part A** is the paste-ready text for *App Store Connect → App Review Information → Notes*.
- **Part B** lists what must be true **before** you paste it, plus the screen-recording shot list.

Facts below were read from the source at `ai.zip1.Foreman`, MARKETING_VERSION 1.0, build 5,
deployment target iOS 26.5, device family iPhone/iPad/visionOS.

---

## Part A — Notes field text

> Fill the `<<< >>>` placeholders before pasting. Do not paste them as-is.

---

**1. Screen recording**

A screen recording captured on a physical <<< e.g. iPhone 17 Pro >>> running iOS <<< 26.x >>> is
attached to this submission. It begins at app launch and covers: the sign-up flow for a new crew
member, the push-notification permission prompt, the weekly schedule with shift creation and
deletion, the shared to-do list with task creation, completion and deletion, account deletion from
the account menu, and sign-out.

Foreman has no paid content, no in-app purchases and no subscriptions, so no purchase flow appears
in the recording. The only system permission prompt the app presents is the standard notification
authorization request; the app does not request location, contacts, camera, microphone, photos, or
App Tracking Transparency.

**2. Devices and operating systems tested**

<<< Replace with the devices you actually tested on. Every entry must be a real physical device or
a clearly labelled simulator. Example format: >>>

- iPhone 17 Pro — iOS 26.x (physical device)
- iPhone 15 — iOS 26.x (physical device)
- iPad Air (M2) — iPadOS 26.x (physical device)
- iPhone 17 Pro Max — iOS 26.x (Simulator, Xcode <<< version >>>)

The app's minimum deployment target is iOS 26.5, so it will not install on earlier OS versions.

**3. What the app does and who it is for**

Foreman is a shared crew scheduling and task board for small hourly teams — restaurants, retail
shops, trades crews, and similar businesses of roughly 2 to 30 people.

Problem it solves: small operators still post the weekly schedule on a paper sheet in the back
office and keep the shift-by-shift task list on a whiteboard. Staff cannot see either one unless
they are physically on site, and changes are communicated by text message or phone call.

Value it provides: the manager posts the week's shifts once, and every crew member sees the same
board on their phone in real time. A shared task list sits alongside it, and each task can be
pinned to a weekday so it shows up in that day's column on the schedule. Anyone on the crew can
check a task off as it is completed.

The app has two roles. **Employees** view the weekly schedule, browse prior and upcoming weeks, and
add, complete and remove items on the shared task list. **Admins** do all of that, plus post and
delete shifts.

Target audience: working adults on a staff roster. The app is not directed at children and contains
no content aimed at minors.

**4. Setup and access instructions**

No sample files are required. Two demo accounts are provided so both roles can be reviewed:

- Admin — Email: `<<< admin demo email >>>`  Password: `<<< password >>>`
- Employee — Email: `<<< employee demo email >>>`  Password: `<<< password >>>`

Steps:

1. Launch the app. The sign-in screen appears with two tabs: **PUNCH IN** (sign in) and
   **NEW CREW MEMBER** (sign up).
2. Enter the admin credentials above on the PUNCH IN tab and tap **Punch In**.
3. Allow the notification prompt if it appears. Notifications are optional; every feature works
   without granting them.
4. The **This Week** tab shows the weekly schedule as seven day columns, scrolling horizontally.
   Use **Prior Week** and **Next Week** to move between weeks. On the admin account, each column
   has a **+ Shift** button that opens a sheet to enter an employee name and start/end times, and
   each posted shift has an **✕** button to remove it. These controls are intentionally hidden on
   the employee account.
5. The **To-Do List** tab shows the shared task list. Type into the field at the bottom, optionally
   pick a weekday from the **Day** menu, and tap **Add**. Tap a checkbox to mark a task complete.
   Swipe a row left to delete it. Tasks assigned to a weekday also appear in that day's column on
   the This Week tab.
6. The account menu is the person icon in the top-right corner of either tab. It shows the signed-in
   user's name and role, and links to the Privacy Policy, Support, <<< Delete Account, >>> and
   **Punch Out** (sign out).
7. To review the sign-up flow, tap **NEW CREW MEMBER** and register any email address and a password
   of at least six characters. New accounts are created with the employee role.
8. <<< To review account deletion: sign in, open the account menu, tap Delete Account and confirm.
   This permanently deletes the account and its profile record. >>>

Both demo accounts remain active and will not be disabled during review.

**5. External services used**

Foreman uses Google Firebase (Google LLC) for all backend functionality. Specifically:

- **Firebase Authentication** — email and password account creation and sign-in. No third-party or
  social sign-in providers are enabled, so Sign in with Apple is not required.
- **Cloud Firestore** — stores user profiles, posted shifts and shared to-do items, and streams
  updates to devices in real time.
- **Firebase Cloud Messaging**, with Apple Push Notification service — delivers schedule change
  notifications. The device push token is stored on the user's own profile record.
- **Google Analytics for Firebase / GoogleAppMeasurement** — bundled as a dependency of the Firebase
  iOS SDK. <<< Confirm whether you actually collect analytics, and make sure this matches your
  App Privacy answers and your privacy policy. If you do not want analytics, disable collection or
  remove the dependency before answering here. >>>

There are no payment processors, no advertising networks, no AI or machine-learning services, and
no third-party data providers. The app makes no network calls to any service other than Google
Firebase and Apple's push infrastructure.

Privacy Policy: https://wordpress-ab119.web.app/privacy.html
Support: https://wordpress-ab119.web.app/support.html

**6. Regional differences**

There are none. Foreman offers identical features and identical content in every region and on every
storefront. There is no geofencing, no region-locked content, no regional pricing, and no
region-dependent behavior. The app is English-only and is not localized. Dates, times and the
Monday-first week layout follow the device's own locale and calendar settings, which is the only
way output can differ between users.

**7. Regulated industries and third-party material**

Foreman does not operate in a regulated industry. It is a general-purpose scheduling and task
tracking tool for small businesses. It does not provide or facilitate financial services, gambling,
healthcare or medical services, legal services, pharmaceuticals, cannabis, insurance, telehealth,
lending, cryptocurrency trading, or any other activity requiring a licence or regulatory approval.

The app contains no protected third-party material. All text, artwork, icons and UI are original
work by the developer. The only third-party components are the open-source Firebase iOS SDK and its
dependencies, used under their respective licences. The app displays no music, video, publisher
content, sports data, brand marks or other licensed material, so no authorization documentation
applies.

---

## Part B — Do these before pasting Part A

### B1. Blocker: the app has no account deletion flow

The reviewer asked for one, and Apple **Guideline 5.1.1(v)** requires apps that support account
creation to also offer in-app account deletion. Foreman creates accounts (`AuthViewModel.signUp`)
but the account menu in `Foreman/MainTabView.swift` offers only Privacy Policy, Support, and
Punch Out. Sign-out is not deletion.

Resubmitting without this will very likely be rejected again on 5.1.1(v) regardless of how good
the notes are. What is needed:

- A **Delete Account** item in the account menu, behind a confirmation.
- It must delete the Firebase Auth user (`user.delete()`, re-authenticating first if Firebase
  returns `requiresRecentLogin`) **and** the `users/{uid}` Firestore profile document.
- Decide what happens to that user's shifts and to-do items and state it in the privacy policy.

The Part A text in items 1, 4 and 6 already includes the wording for this, wrapped in `<<< >>>`.
Delete those wrapped fragments if you ship without deletion — but expect the rejection.

### B2. Blocker: shared content has no reporting or blocking, and no tenant scoping

`ScheduleViewModel.subscribe()` queries `shifts` filtered only by week, and
`TodoViewModel.subscribe()` queries the entire `todos` collection with no filter at all. Neither is
scoped to a company, team or owner. Every signed-up user reads and writes the same global board.

Two consequences:

1. **Privacy.** Anyone who signs up sees every other business's shifts, staff names and tasks, and
   can delete them. An App Review tester will sign up and land in a stranger's data.
2. **Guideline 1.2.** Shift entries and task text are user-generated content visible to other users,
   which triggers the requirement for a content filtering method, a mechanism to report offensive
   content, and the ability to block abusive users.

The fix that resolves both at once is scoping data to a team or organization: add a team identifier
to `UserProfile`, write it onto every `Shift` and `TodoItem`, filter both listeners on it, and
enforce it in Firestore Security Rules. If content is only ever visible to co-workers on the same
invited team, the 1.2 UGC obligations are substantially narrower — but confirm your position before
you claim anything about it in the notes. **Part A deliberately makes no claim about UGC
moderation.** Do not add one until the scoping exists.

Also confirm your **Firestore Security Rules** are not left in test mode. Nothing in this repo
constrains reads or writes; if the rules are open, the entire database is world-readable.

### B3. Admin role cannot be set from inside the app

`AuthViewModel.signUp` hardcodes `role: .employee`. There is no in-app path to become an admin, so
the admin demo account for item 4 must be created by hand: sign the account up in the app, then set
`users/{uid}.role` to `"admin"` in the Firebase console.

This matters for review. A reviewer who just signs up gets the employee role, sees no **+ Shift**
button, and finds a schedule they cannot add anything to — which reads as a broken or incomplete
app. Providing a working admin account is what prevents that. Verify both accounts sign in cleanly
on a real device immediately before you submit.

### B4. Check the push entitlement before archiving

`Foreman/Foreman.entitlements` sets `aps-environment` to `development` and also carries a
non-standard duplicate key `com.apple.developer.aps-environment`. Confirm the archived build
carries the **production** APNs environment, and consider removing the duplicate key. If push does
not work in the reviewed build, do not describe notification features as working.

### B5. Confirm the platform and OS targets you intend

`SUPPORTED_PLATFORMS` is `iphoneos iphonesimulator macosx xros xrsimulator` and
`TARGETED_DEVICE_FAMILY` is `1,2,7` — iPhone, iPad and visionOS. If you are only submitting for
iPhone and iPad, narrow these so App Review does not evaluate the app on Vision Pro or Mac.

Deployment target is **iOS 26.5**, which is unusually high and excludes a large share of devices.
Confirm that is deliberate, and make sure the device you record on runs 26.5 or later.

### B6. Screen recording shot list

Record on a **physical device** on the latest OS, in one unbroken take, portrait, roughly 2–4
minutes. Do not start the recording with the app already open — Apple asks for the launch.

1. Home screen. Tap the Foreman icon. Let the launch play out.
2. Sign-in screen. Tap **NEW CREW MEMBER**. Type a name, a fresh email and a password. Tap
   **Join the Board**. Show the "PUNCHED IN" stamp and the transition into the app.
3. Let the **notification permission prompt** appear on screen and tap Allow. This is the sensitive-
   capability prompt Apple asked to see.
4. **This Week** tab. Scroll horizontally through all seven day columns. Tap **Prior Week**, then
   **Next Week** twice, so week navigation is visible.
5. Sign out via the account menu, then sign back in with the **admin** account so the admin controls
   are visible.
6. Tap **+ Shift** on a day column. Enter an employee name, set start and end times, tap **Save**.
   Show the shift appearing in the column. Then tap the **✕** on it and show it disappearing.
7. **To-Do List** tab. Type a task, pick a weekday from the **Day** menu, tap **Add**. Tap the
   checkbox to complete it. Swipe left and delete it.
8. Return to **This Week** and show a day-assigned task appearing in its weekday column.
9. Open the account menu. Show the name and role line, and tap through to **Privacy Policy** and
   back, then **Support** and back.
10. <<< Account deletion: open the account menu, tap Delete Account, confirm, and show the app
    returning to the signed-out sign-in screen. Then attempt to sign in with the deleted account
    and show that it fails. >>>
11. Tap **Punch Out** and show the return to the sign-in screen.

Upload the file under *App Review Information → Attachment*, or host it and put the link in the
Notes field. Do not send a link that requires a login to open.

### B7. Finally

Paste Part A into *App Store Connect → your app → the version → App Review Information → Notes*,
fill in the Sign-In Required demo account fields with the same admin credentials, attach the
recording, and reply to the reviewer's message in App Store Connect pointing at the updated notes.
Keeping Part A in the Notes field means it carries forward to future submissions, which is what the
reviewer asked for.
