/**
 * Formats a date to GB locale format with dots as separators (dd.mm.yyyy)
 * @param date - The date to format (Date object, string, or timestamp)
 * @returns Formatted date string in dd.mm.yyyy format
 */
export function formatDate(date: Date | string | number): string {
  return new Date(date).toLocaleDateString("en-GB").split("/").join(".");
}
