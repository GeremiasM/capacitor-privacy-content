export interface PrivacyContentPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
}
