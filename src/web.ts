import { WebPlugin } from '@capacitor/core';

import type { PrivacyContentPlugin } from './definitions';

export class PrivacyContentWeb extends WebPlugin implements PrivacyContentPlugin {
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }
}
