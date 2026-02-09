const apiOrigin =
  import.meta.env.VITE_API_ORIGIN ?? import.meta.env.VITE_API_BASE_URL ?? 'http://127.0.0.1:8000'

const normalizedApiOrigin = apiOrigin.endsWith('/') ? apiOrigin.slice(0, -1) : apiOrigin

export function resolveAssetUrl(value) {
  if (value == null) {
    return null
  }

  const raw = String(value).trim()
  if (raw === '') {
    return null
  }

  if (raw.startsWith('http://') || raw.startsWith('https://')) {
    return raw
  }

  if (raw.startsWith('/')) {
    return `${normalizedApiOrigin}${raw}`
  }

  let normalizedPath = raw
  if (normalizedPath.startsWith('public/')) {
    normalizedPath = normalizedPath.slice('public/'.length)
  }

  if (normalizedPath.startsWith('storage/')) {
    return `${normalizedApiOrigin}/${normalizedPath}`
  }

  return `${normalizedApiOrigin}/storage/${normalizedPath}`
}
