import { registerPlugin } from '@capacitor/core';

import type { PrivacyContentPlugin } from './definitions';

const PrivacyContent = registerPlugin<PrivacyContentPlugin>('PrivacyContent', {
  web: () => import('./web').then(m => new m.PrivacyContentWeb()),
});

export * from './definitions';
export { PrivacyContent };
