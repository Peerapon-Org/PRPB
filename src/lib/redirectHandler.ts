export function redirectHandler(
  e: React.MouseEvent<HTMLAnchorElement, MouseEvent>
) {
  const currentPath = window.location.href;
  const targetPath = e.currentTarget.href;

  if (currentPath === targetPath) e.preventDefault();
}
