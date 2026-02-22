# Product Backlog: The Trust Dashboard

## Epic 1: Foundation, Authentication & Settings
**Description:** The basic shell of the application, user entry points, and structural settings.

* **US1.01 - Account Registration:** As a new user, I want to create an account using my email and a password so that I can access the Trust Dashboard.
* **US1.02 - Secure Login & Error Handling:** As a returning user, I want to log in and receive clear error feedback if my credentials are incorrect so that I can securely access my account.
* **US1.03 - The "Covey Home" Welcome:** As a user, I want to see a daily rotating quote from Stephen Covey upon logging in so that my mental model is primed for interdependent work.
* **US1.04 - Profile Management:** As a user, I want to edit my profile details (picture, bio, public name, title) and toggle privacy settings (public/private) so that I control how I appear to my network.
* **US1.05 - App Settings:** As a user, I want to toggle dark/light mode, manage notification preferences, and view app version info so that I can customize my experience.

## Epic 2: The "Clarify Expectations" Workflow
**Description:** The core interactive feature allowing users to make requests, track stalling, and formulate Win-Win agreements.

* **US2.01 - Initiate Request:** As a user, I want to tap a "Clarify Expectations" button and input a description, document ID, and target peers so that I can formally ask for help or involvement.
* **US2.02 - Request Visibility (Bubbles):** As a user, I want my active requests to appear as colored bubbles next to my persona icon so that others in the network can see I need assistance.
* **US2.03 - Dynamic Time-Based Statuses:** As a user, I want my request bubble to automatically change from Fair (Blue) to Normal (Yellow - 3 days) to Critical (Red - 5 days) so that the urgency of stalled tasks is visible.
* **US2.04 - The "Talk Straight" Prompt:** As a user with a request stalled for X days, I want to receive a prompt to either "Talk Straight" or "Revise Request" so that I can unblock the friction proactively.
* **US2.05 - Win-Win Performance Agreement:** As a peer responding to a request, I want the system to prompt me to fill out the 5 elements (Results, Guidelines, Resources, Accountability, Consequences) so that expectations are crystal clear before work begins.
* **US2.06 - Event Interaction Points:** As a user, I want to be awarded Fair, Normal, or High Trust points depending on whether I interact with, counter, or complete a "Clarify Expectations" agreement.

## Epic 3: The "Network" Node Map & Roster
**Description:** The visual representation of relationships, contacts, and "rear mirrors."

* **US3.01 - Persona Node Center:** As a user, I want to see my persona icon in the center of the "Network" tab so that I have a visual starting point of my reach.
* **US3.02 - Acquaintance Connections:** As a user, I want to see connection lines to peers I have interacted with so that I can visualize my active network.
* **US3.03 - Contact Syncing:** As a user, I want to securely sync my phone contacts so that I can discover and map existing peers who are already on the platform.
* **US3.04 - Node Hover Info:** As a user, I want to long-tap on a peer's node to see a brief summary (e.g., 5 Waves of Trust status, strengths) so that I can quickly assess our working relationship.
* **US3.05 - Map Navigation:** As a user, I want to drag to pan and pinch to zoom in/out of the node map so that I can easily navigate large organizational networks.
* **US3.06 - The Vertical Roster:** As a user, I want a standard list view of my network showing basic statuses and contact info so that I can quickly scroll through peers without using the visual map.

## Epic 4: Behavioral Analytics & The Trust Counter (EB)
**Description:** The gamification, scoring, and knowledge base tracking.

* **US4.01 - Baseline Initialization:** As a new user, I want to start with a baseline of 300 Trust points so that I have immediate standing in the Emotional Bank Account system.
* **US4.02 - Active Point Generation:** As a user, I want to earn daily capped points (1-10) for sending chats and asking inquisitive questions (4-30) so that my proactive communication is rewarded.
* **US4.03 - Passive "Listening" Generation:** As a user, I want to earn high points (7-100) for passively reading chats or hovering over requests so that my effort to "Seek First to Understand" is heavily incentivized.
* **US4.04 - The "Trusted" Status:** As a user who exceeds 350 points, I want the "Trusted" label to appear on my profile so that my reliability is visible to my network.
* **US4.05 - The Knowledge Base:** As a user, I want to access built-in blogs about the 7 Habits and earn points for reading them so that I am encouraged to learn the platform's philosophy.
* **US4.06 - Lead/Lag Metrics Dashboard:** As a user, I want to view my Lead measures, Lag measures, and quantified "Trust Tax" visualizations on the home screen so that I can track my performance objectively.

## Epic 5: "Trust Units" & System Administration
**Description:** Tools for designated EQ experts and platform administrators to manage the ecosystem.

* **US5.01 - Role-Based Access:** As a Trust Unit/Admin, I want a specific role designation so that I can access the "Super User" dashboard.
* **US5.02 - Private Status Assignment:** As a Trust Unit, I want to assign private statuses (e.g., "Low Trust", "Troublemaker", "Proactive") to users so that I can categorize network health behind the scenes.
* **US5.03 - Withdrawal Marker Detection:** As a Trust Unit, I want the system to flag "Withdrawal Markers" (e.g., high friction, unresponsive chats) so that I know where my intervention is needed.
* **US5.04 - AI Helper Prompts:** As a Trust Unit, I want the system to suggest templates or mediation strategies for stalled nodes so that I can efficiently coach teams toward Win-Win agreements.