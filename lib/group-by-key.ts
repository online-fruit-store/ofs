/**
 * Takes an array of [key, value] pairs and returns an object where:
 *   - Each key with exactly one value becomes: key -> string
 *   - Each key with multiple values becomes: key -> string[]
 *
 * @param entries - An array of [key, value] pairs
 * @returns An object mapping each key to either a string or an array of strings
 */
export function groupByKey(
  entries: [string, string][],
): Record<string, string | string[]> {
  return entries.reduce<Record<string, string | string[]>>(
    (acc, [key, value]) => {
      // If we have not seen this key before, store it as a single string
      if (acc[key] === undefined) {
        acc[key] = value;
      }
      // If we've seen the key before and it's a string, convert to array
      else if (typeof acc[key] === "string") {
        acc[key] = [acc[key] as string, value];
      }
      // If we've already converted it to an array, just push the new value
      else {
        (acc[key] as string[]).push(value);
      }
      return acc;
    },
    {},
  );
}
