import type { AirportPoint, MiningAssetPoint, PortPoint } from '../types';

export function matchesAirportFilter(
  point: AirportPoint,
  selectedOptions: string[]
): boolean {
  if (!selectedOptions.some((id) => id.startsWith('airports-'))) return false;

  const type = point.airport_type?.toLowerCase() ?? '';

  if (selectedOptions.includes('airports-large') && type.includes('large')) return true;
  if (selectedOptions.includes('airports-medium') && type.includes('medium')) return true;
  if (selectedOptions.includes('airports-small') && type.includes('small')) return true;

  return false;
}

export function matchesPortFilter(
  point: PortPoint,
  selectedOptions: string[]
): boolean {
  if (!selectedOptions.some((id) => id.startsWith('ports-'))) return false;
  if (selectedOptions.includes('ports-all')) return true;

  const portType = point.port_type?.toLowerCase() ?? '';
  const sizeClass = point.size_class?.toLowerCase() ?? '';
  const harborUse = point.harbor_use?.toLowerCase() ?? '';

  if (selectedOptions.includes('ports-container') && point.has_container) return true;
  if (selectedOptions.includes('ports-oil') && point.has_oil_terminal) return true;
  if (selectedOptions.includes('ports-lng') && point.has_lng_terminal) return true;

  if (selectedOptions.includes('ports-commercial') && harborUse.includes('commercial')) return true;
  if (selectedOptions.includes('ports-industrial') && harborUse.includes('industrial')) return true;
  if (selectedOptions.includes('ports-fishing') && harborUse.includes('fishing')) return true;
  if (selectedOptions.includes('ports-naval') && harborUse.includes('naval')) return true;

  if (selectedOptions.includes('ports-large') && sizeClass.includes('large')) return true;
  if (selectedOptions.includes('ports-medium') && sizeClass.includes('medium')) return true;
  if (selectedOptions.includes('ports-small') && sizeClass.includes('small')) return true;

  if (selectedOptions.includes('ports-river') && portType.includes('river')) return true;
  if (selectedOptions.includes('ports-coastal') && portType.includes('coastal')) return true;
  if (
    selectedOptions.includes('ports-lake') &&
    (portType.includes('lake') || portType.includes('canal'))
  ) {
    return true;
  }

  return false;
}

export function matchesMiningFilter(
  point: MiningAssetPoint,
  selectedOptions: string[]
): boolean {
  if (!selectedOptions.some((id) => id.startsWith('mining-'))) return false;
  if (selectedOptions.includes('mining-all')) return true;

  const entityType = point.entityType?.toLowerCase() ?? '';
  const assetType = point.assetTypeRaw?.toLowerCase() ?? '';
  const primary = point.primaryCommodity?.toLowerCase() ?? '';
  const group = point.commodityGroup?.toLowerCase() ?? '';
  const all = point.allCommodities?.join(' ').toLowerCase() ?? '';

  const haystack = `${entityType} ${assetType} ${primary} ${group} ${all}`;

  if (selectedOptions.includes('mining-mines') && haystack.includes('mine')) return true;
  if (selectedOptions.includes('mining-smelters') && haystack.includes('smelter')) return true;
  if (selectedOptions.includes('mining-refineries') && haystack.includes('refiner')) return true;
  if (selectedOptions.includes('mining-plants') && haystack.includes('plant')) return true;
  if (selectedOptions.includes('mining-mixed') && haystack.includes('mixed')) return true;

  if (selectedOptions.includes('mining-copper') && haystack.includes('copper')) return true;
  if (selectedOptions.includes('mining-gold') && haystack.includes('gold')) return true;
  if (selectedOptions.includes('mining-iron') && haystack.includes('iron')) return true;
  if (selectedOptions.includes('mining-coal') && haystack.includes('coal')) return true;
  if (selectedOptions.includes('mining-lithium') && haystack.includes('lithium')) return true;
  if (selectedOptions.includes('mining-nickel') && haystack.includes('nickel')) return true;
  if (selectedOptions.includes('mining-zinc') && haystack.includes('zinc')) return true;
  if (selectedOptions.includes('mining-cobalt') && haystack.includes('cobalt')) return true;
  if (selectedOptions.includes('mining-uranium') && haystack.includes('uranium')) return true;

  if (
    selectedOptions.includes('mining-ree') &&
    (haystack.includes('rare earth') || haystack.includes('ree'))
  ) {
    return true;
  }

  return false;
}