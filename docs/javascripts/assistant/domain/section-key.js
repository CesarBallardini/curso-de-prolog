// Two locations are the same section when they are in the same chapter and have the same
// heading slug, ignoring the leading section number and a trailing _N: the chapter's index
// page holds a stub and its extra page the full text, under the same heading.
export function sectionKey(location) {
  const [path, fragment = ''] = location.split('#');
  const chapter = path.split('/')[0];
  const slug = fragment.replace(/^\d+-/, '').replace(/_\d+$/, '');
  return slug ? `${chapter}#${slug}` : location;
}
export const sameSection = (a, b) => a === b || sectionKey(a) === sectionKey(b);
