export function transformName (name: string): string {
    return name
        .replaceAll("_", " ")
        .replace(/\b\w/g, (l: string) => l.toUpperCase());
};