import 'package:saaf/core/config/legal_config.dart';
import 'package:saaf/core/config/policy_version.dart';

/// One headed section of a legal document.
class LegalSection {
  const LegalSection(
    this.heading, {
    this.paragraphs = const [],
    this.bullets = const [],
  });

  final String heading;
  final List<String> paragraphs;
  final List<String> bullets;
}

class LegalDocument {
  const LegalDocument({
    required this.title,
    required this.lastUpdated,
    required this.intro,
    required this.sections,
  });

  final String title;

  /// The policy version (a date), same as the one stored with the user's consent.
  final String lastUpdated;
  final String intro;
  final List<LegalSection> sections;
}

/// The Terms of Use and Privacy Policy (English). They describe what the app
/// actually does (docs/architecture.md PRV-1..4, docs/store-compliance.md) and
/// must be kept in step with it; bump [currentPolicyVersion] when they change.
/// DRAFT: have a lawyer review them before release (see LegalConfig.isReviewed).
abstract final class LegalDocuments {
  static String _contact(LegalConfig c) => c.hasContactEmail
      ? 'You can contact us at ${c.contactEmail}.'
      : 'You can contact us from the Help section of your Saaf profile or through our '
            'App Store and Google Play listing.';

  static LegalDocument terms(LegalConfig c) => LegalDocument(
    title: 'Terms of Use',
    lastUpdated: currentPolicyVersion,
    intro:
        'These Terms of Use are an agreement between you and ${c.operatorName} '
        '("we", "us") about your use of the Saaf app. By creating an account or '
        'using Saaf you agree to them and to our Privacy Policy. If you do not '
        'agree, please do not use Saaf.',
    sections: [
      const LegalSection(
        '1. Who can use Saaf',
        paragraphs: [
          'You must be at least 16 years old and able to enter into an '
              'agreement. You promise that the information you give us is true '
              'and that you use Saaf only for yourself.',
        ],
      ),
      const LegalSection(
        '2. Your account',
        paragraphs: [
          'You sign in with your mobile number, or with your Apple or Google '
              'account. Keep your phone and sign-in secure: you are responsible '
              'for what happens under your account. Tell us if you think someone '
              'else is using it.',
        ],
      ),
      const LegalSection(
        '3. What Saaf is, and what it is not',
        paragraphs: [
          'Saaf is a cosmetic skincare coach. It is not medical advice, it does '
              'not diagnose or treat any condition, and it is not a substitute '
              'for a doctor or dermatologist.',
          'Skin checks and routines are estimates made from your photos and '
              'answers, and they can be wrong. Patch-test new products and stop '
              'using anything that irritates you. See a dermatologist for '
              'persistent, painful or changing skin problems, and ask your doctor '
              'before using active ingredients if you are pregnant, breastfeeding '
              'or on prescription treatment.',
        ],
      ),
      const LegalSection(
        '4. Your photos and answers',
        paragraphs: [
          'You keep ownership of your photos and answers. You give us permission '
              'to process them only as needed to run Saaf for you, as explained '
              'in the Privacy Policy. Only add photos of yourself.',
        ],
      ),
      const LegalSection(
        '5. Using Saaf properly',
        paragraphs: ['You agree not to:'],
        bullets: [
          'break the law or other people\'s rights using Saaf',
          'copy, reverse-engineer or interfere with the app or its servers',
          'use bots or scrapers, or try to get into other people\'s accounts',
          'misuse the product information, routines or scores we show you',
        ],
      ),
      const LegalSection(
        '6. Saaf Pro subscriptions',
        paragraphs: [
          'Some features need a Saaf Pro subscription. The price, length and any '
              'free trial are shown in the app in your local currency before you '
              'subscribe.',
          'Payment is taken by Apple (App Store) or Google (Google Play), not by '
              'us. Your subscription will automatically renew at the end of each '
              'period unless you cancel at least 24 hours before it ends. Manage '
              'or cancel it in your Apple ID settings (Subscriptions) or in Google '
              'Play (Payments and subscriptions). Deleting your Saaf account does '
              'not cancel a subscription, so cancel first.',
          'You pay with whatever your store account offers: a debit or credit '
              'card, Google Pay, Apple Pay, your mobile carrier or store balance. '
              'The store handles the payment, not us, so we never see your card '
              'or bank details.',
          'Price changes follow the rules of the store you bought from, which '
              'tells you before a higher price applies. A free trial turns into a '
              'paid subscription unless you cancel before it ends.',
        ],
      ),
      const LegalSection(
        '7. Refunds',
        paragraphs: [
          'Because Apple or Google takes the payment, refunds are decided by '
              'them under their own rules, and we cannot refund a store payment '
              'ourselves. Your rights under consumer law are not affected.',
        ],
        bullets: [
          'App Store: ask Apple at reportaproblem.apple.com, or contact Apple '
              'Support.',
          'Google Play: within 48 hours of buying you can ask for a refund '
              'yourself in Google Play (play.google.com, Account, Order '
              'history). After 48 hours, contact us and we will look at your '
              'request, or ask Google Play support.',
          'Cancelling stops the next renewal; the period you already paid for '
              'stays usable until it ends.',
        ],
      ),
      const LegalSection(
        '8. Product information and links',
        paragraphs: [
          'Saaf shows products, ingredients and prices gathered from third '
              'parties. They may be out of date or wrong, and a product being '
              'suggested is not a promise it will suit you. "Buy" links open '
              'other companies\' websites or apps; your purchase is with them, '
              'under their terms. If we ever earn a commission from a link, we '
              'will say so next to it.',
        ],
      ),
      const LegalSection(
        '9. Our content',
        paragraphs: [
          'The app, its design, text, routines and scoring belong to us or our '
              'licensors. You may use them personally, not commercially. All '
              'rights not given to you are kept.',
        ],
      ),
      const LegalSection(
        '10. Changes to Saaf',
        paragraphs: [
          'We may add, change or remove features, and Saaf may sometimes be '
              'unavailable. We will try to give notice of changes that matter to you.',
        ],
      ),
      const LegalSection(
        '11. Ending your use',
        paragraphs: [
          'You can stop at any time and delete your account in the app '
              '(Profile, then Privacy, then Delete my account). We may suspend or '
              'close an account that breaks these terms. When an account is '
              'deleted we delete its data as described in the Privacy Policy.',
        ],
      ),
      const LegalSection(
        '12. No guarantees',
        paragraphs: [
          'Saaf is provided "as is". Skin results vary from person to person and '
              'there is no guarantee that any routine or product will improve '
              'your skin. To the extent the law allows, we do not promise that '
              'Saaf will always work or be free of errors.',
        ],
      ),
      const LegalSection(
        '13. Our responsibility',
        paragraphs: [
          'To the extent the law allows, we are not responsible for indirect or '
              'consequential losses, or for harm from using a product you chose. '
              'Nothing in these terms limits liability that cannot be limited by law.',
        ],
      ),
      const LegalSection(
        '14. Changes to these terms',
        paragraphs: [
          'We may update these terms. When we make a material change we will tell '
              'you in the app and ask you to accept the new version. Using Saaf '
              'after that means you accept it.',
        ],
      ),
      const LegalSection(
        '15. Governing law',
        paragraphs: [
          'These terms are governed by the laws of Pakistan, and the courts of '
              'Pakistan can decide disputes about them, without affecting any '
              'rights you have under the law where you live.',
        ],
      ),
      LegalSection('16. Contact us', paragraphs: [_contact(c)]),
    ],
  );

  static LegalDocument privacy(LegalConfig c) => LegalDocument(
    title: 'Privacy Policy',
    lastUpdated: currentPolicyVersion,
    intro:
        'Saaf checks your skin, not your identity. This policy explains what '
        '${c.operatorName} ("we", "us") collects when you use the Saaf app, why, '
        'who it is shared with, how long we keep it and how you can delete it. '
        'Saaf is for people aged 16 and over.',
    sections: [
      const LegalSection(
        '1. What we collect',
        bullets: [
          'Your sign-in details: your mobile number, or the identifier Apple or '
              'Google gives us (and your email address if you allow it).',
          'Your skin profile: your answers on skin type, concerns, sensitivity '
              'and monthly budget, plus your routine and check-ins.',
          'Safety answers: whether you are pregnant or breastfeeding, on a '
              'prescription skin treatment, or have an ingredient allergy. These '
              'stay on your phone and are never uploaded.',
          'Face photos you take for skin checks. These stay on your phone '
              '(see section 3).',
          'Your subscription status, if you subscribe. Payment details go to '
              'Apple or Google; we never see your card.',
          'Technical information that our service providers need to keep Saaf '
              'working and secure, such as your IP address and app and device '
              'identifiers.',
          'A record that you accepted our Terms and this policy, with the date '
              'and version.',
          'If you use the optional AI coach: the questions you type and the '
              'photos you attach there (see section 6).',
        ],
      ),
      const LegalSection(
        '2. What we do not collect',
        paragraphs: [
          'We do not access your contacts or your location. We do not collect '
              'your advertising ID. Saaf contains no advertising and no tracking '
              'or analytics tools. Your data is never sold or shared with '
              'advertisers or brands.',
          'Cookies: the Saaf app does not use cookies, and neither do our web '
              'pages (this policy, the terms and the account deletion page), so '
              'there is nothing to accept or turn off.',
          'Payments: we never receive your card, Google Pay or Apple Pay '
              'details; Apple or Google handles them.',
        ],
      ),
      const LegalSection(
        '3. Your face photos',
        paragraphs: [
          'Photos you take are saved in private storage on your phone, not in '
              'your gallery. The skin analysis runs on your device, so your '
              'photos are not sent to us or to anyone else to be analysed. Photos '
              'are never uploaded unless you turn on backup, which is off by '
              'default. If you turn it on, your photos are copied to your account '
              'storage and deleted with your account. Your photos are never sent '
              'anywhere else, except photos you choose to attach to a question, '
              'or the progress photos you choose to send for an AI progress '
              'review, in the optional AI coach (see section 6). If we ever add another '
              'feature that sends a photo or skin data elsewhere, we will ask '
              'for your permission first, and say who receives it.',
        ],
      ),
      const LegalSection(
        '4. How we use your data',
        bullets: [
          'to sign you in and keep your account secure',
          'to build and adjust your routine from your profile and check-ins',
          'to analyse your skin on your device',
          'to sync your profile and routine between your devices (never your '
              'photos unless you turn on backup, and never your safety answers)',
          'to manage your subscription',
          'to answer your questions and keep Saaf safe and working',
        ],
      ),
      const LegalSection(
        '5. Who receives your data',
        paragraphs: [
          'We use a few service providers who handle data only on our '
              'instructions and must protect it as this policy describes:',
        ],
        bullets: [
          'Google (Firebase): sign-in by mobile number, and the cloud storage '
              'for your account data.',
          'Apple and Google: Sign in with Apple, Google sign-in, and payment for '
              'subscriptions.',
          'RevenueCat: keeps track of whether your subscription is active.',
          'Only if you use the AI coach: Cloudflare, which runs the small '
              'server that passes your question on, and Groq, which runs the '
              'open-source AI model that writes the reply (see section 6).',
          'Open Beauty Facts, a free open database: when you scan a product '
              'barcode, only the barcode number is sent to look the product up.',
          'Google or Apple speech recognition: only if you tap the microphone '
              'in the AI coach, your phone’s own speech service turns your voice '
              'into text. Saaf receives only the text.',
          'Open-Meteo: if you choose a city for the daily skin weather, our '
              'server asks Open-Meteo for that city’s weather and air quality. '
              'Only the city’s place is sent, never your exact location.',
        ],
      ),
      const LegalSection(
        '6. The AI coach (optional)',
        paragraphs: [
          'The AI coach is optional. It only works after you read a short '
              'notice in the app and agree. If you then ask a question, we send: '
              'the message you type, the photos you attach, and a few facts so '
              'the advice fits you: your skin type, skin concerns, sensitivity, '
              'monthly budget band and the names of the products in your '
              'routine. Your skin results come from Saaf AI estimating your skin '
              'from the FRONT photo of a scan: you are asked first, and you can '
              'choose to have every new scan analysed automatically (you can '
              'turn this off in Profile at any time). The estimate is kept on '
              'your phone. '
              'In an AI progress review you can send your first, previous and '
              'latest FRONT photos together, after seeing exactly which photos '
              'will be sent; your side photos are never sent. We never send your '
              'name, phone number or email, or your '
              'safety answers (pregnancy or breastfeeding, prescription skin '
              'treatment, ingredient allergy).',
          'With the AI coach on, Saaf AI also chooses the products for your '
              'routine and reviews the products you told us you use now. For '
              'that we send the facts above, the names of the products you use '
              'now and your latest scan scores (four numbers, never the '
              'photos). The AI model searches the web, including public '
              'review pages and Reddit, for products and reviews; your safety '
              'answers are never sent, and your phone checks its suggestions '
              'against them. When you '
              'look a product up or check a cream for harmful ingredients, we send '
              'only what you choose: its name, its barcode '
              'number, the text of its QR code, or a photo of its label. The AI '
              'model may search the web for that product; it never searches for '
              'you.',
          'Our server, run on Cloudflare, checks that you are signed in and '
              'passes your question to Groq, which runs an open-source AI model '
              'to write the reply. Groq handles it under its own privacy terms. '
              'We do not store your questions, photos or the replies on our '
              'server, and the conversation stays in the app only until you '
              'close it or start a new chat. If you report a reply, we keep that '
              'reply and your reason so we can review it.',
          'Photos of your face are sensitive, so only attach a photo if you are '
              'comfortable sending it. AI replies can be wrong and are not '
              'medical advice; see a dermatologist for painful, spreading or '
              'worrying skin changes.',
        ],
        bullets: [
          'You can stop sharing at any time in Profile. This also clears the '
              'conversation.',
          'When Saaf AI builds your routine (only after it has read a face '
              'scan), we send your skin facts as above, the latest scan estimates '
              '(numbers, not the photo), and the products you use now: their '
              'names, their kind and, if you added them, their prices, so new '
              'products fit what is left of your budget. Saaf AI searches the web '
              'for products sold in Pakistan and for what real users say in '
              'reviews (for example on Reddit), and suggests a few options for '
              'each step for you to choose from.',
          'Deleting your account removes the permission you gave.',
        ],
      ),
      const LegalSection(
        '7. Where your data is handled',
        paragraphs: [
          'Our providers run servers in several countries, so your data may be '
              'handled outside Pakistan. They protect it with security measures '
              'and contractual commitments.',
        ],
      ),
      const LegalSection(
        '8. How long we keep it',
        paragraphs: [
          'We retain your account data until you delete your account. Photos and '
              'safety answers stay on your phone until you delete them or '
              'uninstall Saaf. When you delete your account we delete your '
              'account data and any backed-up photos; copies in our providers\' '
              'backups are removed within 30 days. We may retain limited records '
              'where the law requires it, such as payment records held by Apple '
              'or Google.',
        ],
      ),
      LegalSection(
        '9. Your choices and rights',
        paragraphs: [
          'You can access and correct your profile in the app, turn photo backup '
              'on or off, and take back permissions (such as the camera) in your '
              'phone\'s settings. You can withdraw your consent and delete your '
              'data at any time:',
        ],
        bullets: [
          'In the app: Profile, then Privacy, then Delete my account. This '
              'permanently deletes your account and data.',
          if (c.hasDeletionUrl)
            'On the web, without the app: ${c.deletionUrl}'
          else
            'Or contact us and we will delete it for you.',
          'Deleting your account does not cancel a subscription. Cancel it in '
              'the App Store or Google Play first.',
        ],
      ),
      const LegalSection(
        '10. Security',
        paragraphs: [
          'Data is sent over encrypted connections, and sign-in tokens are kept '
              'in your phone\'s secure storage. No system is perfectly secure, so '
              'please protect your phone with a lock.',
        ],
      ),
      const LegalSection(
        '11. Children',
        paragraphs: [
          'Saaf is not for anyone under 16. If we learn that a younger person has '
              'an account, we will delete it.',
        ],
      ),
      const LegalSection(
        '12. The law that applies',
        paragraphs: [
          'We handle your data with your consent and to provide Saaf to you, '
              'following good-practice principles: asking before collecting, '
              'collecting only what we need, keeping it secure, and letting you '
              'delete it. We will follow Pakistani data-protection law as it '
              'comes into force.',
        ],
      ),
      const LegalSection(
        '13. Changes to this policy',
        paragraphs: [
          'If we change how we handle your data in a material way, we will tell '
              'you in the app and ask for your consent again before the change '
              'applies to you.',
        ],
      ),
      LegalSection('14. Contact us', paragraphs: [_contact(c)]),
    ],
  );
}
