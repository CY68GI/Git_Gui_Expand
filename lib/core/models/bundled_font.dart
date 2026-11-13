class BundledFontOption {
  const BundledFontOption({
    required this.family,
    required this.label,
    required this.description,
    required this.sourceUrl,
    required this.licenseAsset,
  });

  final String family;
  final String label;
  final String description;
  final String sourceUrl;
  final String licenseAsset;
}

const List<BundledFontOption> bundledUiFonts = [
  BundledFontOption(
    family: 'Inter UI',
    label: 'Inter UI',
    description: '专为数字界面设计的开源无衬线字体，适合工具栏和高密度正文。',
    sourceUrl: 'https://fonts.google.com/specimen/Inter',
    licenseAsset: 'assets/fonts/LICENSE-Inter.txt',
  ),
  BundledFontOption(
    family: 'Noto Sans SC',
    label: 'Noto Sans SC / 思源黑体',
    description: '覆盖简体中文的现代界面字体，中英文混排清晰、字形稳定。',
    sourceUrl: 'https://fonts.google.com/noto/specimen/Noto+Sans+SC',
    licenseAsset: 'assets/fonts/LICENSE-NotoSansSC.txt',
  ),
  BundledFontOption(
    family: 'IBM Plex Sans',
    label: 'IBM Plex Sans',
    description: '为产品界面和企业信息设计，数字与英文阅读性突出。',
    sourceUrl: 'https://fonts.google.com/specimen/IBM+Plex+Sans',
    licenseAsset: 'assets/fonts/LICENSE-IBMPlexSans.txt',
  ),
];
