export interface DataThermPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
}
