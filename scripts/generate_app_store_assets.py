from __future__ import annotations

from pathlib import Path
from PIL import Image, ImageDraw, ImageFont, ImageFilter

ROOT = Path('/Users/larry/Documents/PDF Librarian')
ASSETS = ROOT / 'docs' / 'assets'
RAW = ASSETS / 'appstore-raw'
OUT = ROOT / 'docs' / 'app-store'
SCREEN_OUT = OUT / 'screenshots'
PREVIEW_OUT = OUT / 'preview'

W, H = 2880, 1800
PW, PH = 1920, 1080

EN_TITLE_FONT = '/System/Library/Fonts/Avenir Next.ttc'
EN_BODY_FONT = '/System/Library/Fonts/SFNS.ttf'
CN_TITLE_FONT = '/System/Library/Fonts/STHeiti Medium.ttc'
CN_BODY_FONT = '/System/Library/Fonts/Hiragino Sans GB.ttc'
MONO_FONT = '/System/Library/Fonts/SFNSMono.ttf'
FALLBACK_FONT = '/System/Library/Fonts/Supplemental/Arial Unicode.ttf'
LOGO = ASSETS / 'PDFLibrarian-logo-1024.png'

SLIDES = {
    'en-US': [
        {
            'eyebrow': 'PRECISE LOOKUP',
            'title': 'Search from file names\nand PDF hints',
            'subtitle': 'Load a folder of PDFs, extract filename clues, and prepare a focused search in one place.',
            'points': [
                'Scan folders recursively',
                'Read title, ISBN, and DOI hints',
                'Start from a clean shortlist',
            ],
            'image': ASSETS / 'pdflibrarian-en-light-full.png',
            'theme': 'light',
        },
        {
            'eyebrow': 'COMPARE SOURCES',
            'title': 'Compare ranked public\nmetadata candidates',
            'subtitle': 'Review merged results from multiple sources before choosing the record that should drive the write.',
            'points': [
                'Merged ranking across sources',
                'Confidence and validation chips',
                'One candidate drives the next step',
            ],
            'image': RAW / 'en-candidates-dark.png',
            'theme': 'dark',
        },
        {
            'eyebrow': 'EDIT BEFORE WRITE',
            'title': 'Review and edit\nDublin Core fields',
            'subtitle': 'Check every field before metadata is written back to the selected PDF.',
            'points': [
                'Editable values in place',
                'Selectable field set',
                'Predictable write result',
            ],
            'image': RAW / 'en-edit-dark.png',
            'theme': 'dark',
        },
        {
            'eyebrow': 'RENAME CLEANLY',
            'title': 'Rename from the latest\nwritten metadata',
            'subtitle': 'Generate a consistent file name from the latest write and still allow a final manual edit.',
            'points': [
                'Suggestion from fresh metadata',
                'Final filename stays editable',
                'Cleaner library naming',
            ],
            'image': RAW / 'en-edit-dark.png',
            'theme': 'dark',
            'mock': 'rename',
        },
        {
            'eyebrow': 'DAYLIGHT + MOONLIGHT',
            'title': 'Work in English or Chinese\nwith refined light and dark modes',
            'subtitle': 'A desktop workflow built for long cleanup sessions across bright and dark environments.',
            'points': [
                'English and Chinese UI',
                'Daylight and Moonlight modes',
                'Polished for daily library work',
            ],
            'image': RAW / 'en-top-dark.png',
            'theme': 'dark',
        },
    ],
    'zh-Hans': [
        {
            'eyebrow': '精准检索',
            'title': '文件名与 PDF 线索\n驱动精准检索',
            'subtitle': '加载 PDF 后统一提取标题、ISBN 与 DOI 线索并开始联机检索。',
            'points': [
                '递归扫描文件夹中的 PDF',
                '自动提取标题与编号线索',
                '从干净候选集开始筛选',
            ],
            'image': ASSETS / 'pdflibrarian-zh-Hans-light-full.png',
            'theme': 'light',
        },
        {
            'eyebrow': '候选对比',
            'title': '对比并合并\n候选元数据结果',
            'subtitle': '先看多来源候选及置信度，再决定哪条记录进入写入流程。',
            'points': [
                '跨来源合并与排序',
                '带置信度与来源标记',
                '选定后进入确认写入',
            ],
            'image': RAW / 'zh-candidates-dark.png',
            'theme': 'dark',
        },
        {
            'eyebrow': '写入前确认',
            'title': '写入前确认并编辑\nDublin Core 字段',
            'subtitle': '逐项查看并修改字段内容，确保写回 PDF 的就是最终确认值。',
            'points': [
                '字段可逐项编辑',
                '仅写入最终确认值',
                '写入结果更可预期',
            ],
            'image': RAW / 'zh-edit-dark.png',
            'theme': 'dark',
        },
        {
            'eyebrow': '标准命名',
            'title': '基于最新元数据\n完成标准重命名',
            'subtitle': '按刚写入的元数据生成建议文件名，并保留最后一次手动修改。',
            'points': [
                '建议名来自最新元数据',
                '最终文件名仍可改',
                '统一资料库命名规则',
            ],
            'image': RAW / 'zh-edit-dark.png',
            'theme': 'dark',
            'mock': 'rename',
        },
        {
            'eyebrow': '双语与双模式',
            'title': '支持中英双语与\n日光、月光工作模式',
            'subtitle': '适合长时间整理图书和文献 PDF，同时兼顾亮色与暗色桌面环境。',
            'points': [
                '中英文界面',
                '日光与月光模式',
                '适合书籍、论文与参考资料',
            ],
            'image': RAW / 'zh-top-dark.png',
            'theme': 'dark',
        },
    ],
}

PREVIEWS = {
    'en-US': {
        'eyebrow': 'PDF LIBRARIAN',
        'title': 'Clean PDF metadata\nand rename with context',
        'subtitle': 'Search, confirm, write, and rename in one calmer desktop workflow.',
        'points': ['Multi-source lookup', 'Editable Dublin Core write'],
    },
    'zh-Hans': {
        'eyebrow': 'PDF LIBRARIAN',
        'title': '整理 PDF 元数据\n并标准重命名',
        'subtitle': '完成检索、确认、写入与重命名，让资料库更整洁。',
        'points': ['多源检索', '可编辑写入'],
    },
}


def font(path: str, size: int) -> ImageFont.FreeTypeFont:
    try:
        return ImageFont.truetype(path, size=size)
    except Exception:
        return ImageFont.truetype(FALLBACK_FONT, size=size)


def rounded(img: Image.Image, radius: int) -> Image.Image:
    mask = Image.new('L', img.size, 0)
    d = ImageDraw.Draw(mask)
    d.rounded_rectangle((0, 0, img.size[0], img.size[1]), radius=radius, fill=255)
    out = img.convert('RGBA')
    out.putalpha(mask)
    return out


def gradient(size: tuple[int, int], top: tuple[int, int, int], bottom: tuple[int, int, int]) -> Image.Image:
    w, h = size
    img = Image.new('RGB', size)
    px = img.load()
    for y in range(h):
        t = y / max(h - 1, 1)
        r = int(top[0] * (1 - t) + bottom[0] * t)
        g = int(top[1] * (1 - t) + bottom[1] * t)
        b = int(top[2] * (1 - t) + bottom[2] * t)
        for x in range(w):
            px[x, y] = (r, g, b)
    return img


def add_glow(base: Image.Image, bbox: tuple[int, int, int, int], color: tuple[int, int, int, int], blur: int) -> None:
    layer = Image.new('RGBA', base.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    d.rounded_rectangle(bbox, radius=240, fill=color)
    layer = layer.filter(ImageFilter.GaussianBlur(blur))
    base.alpha_composite(layer)


def fit_image(img: Image.Image, max_w: int, max_h: int) -> Image.Image:
    ratio = min(max_w / img.width, max_h / img.height)
    return img.resize((int(img.width * ratio), int(img.height * ratio)), Image.Resampling.LANCZOS)


def contains_cjk(text: str) -> bool:
    return any('\u4e00' <= ch <= '\u9fff' for ch in text)


def wrap_text(draw: ImageDraw.ImageDraw, text: str, font_obj, max_width: int, spacing: int = 8) -> str:
    lines: list[str] = []
    for para in text.split('\n'):
        if not para:
            lines.append('')
            continue
        cjk = contains_cjk(para)
        units = list(para) if cjk else para.split(' ')
        joiner = '' if cjk else ' '
        current = ''
        for unit in units:
            candidate = unit if not current else current + joiner + unit
            bbox = draw.multiline_textbbox((0, 0), candidate, font=font_obj, spacing=spacing)
            if bbox[2] - bbox[0] <= max_width:
                current = candidate
            else:
                if current:
                    lines.append(current)
                current = unit
        if current:
            lines.append(current)
    return '\n'.join(lines)


def chip(draw: ImageDraw.ImageDraw, xy: tuple[int, int], text: str, body_font, fill, stroke, text_fill):
    x, y = xy
    box = draw.textbbox((0, 0), text, font=body_font)
    w = box[2] - box[0] + 34
    h = box[3] - box[1] + 18
    draw.rounded_rectangle((x, y, x + w, y + h), radius=20, fill=fill, outline=stroke, width=2)
    draw.text((x + 17, y + h / 2), text, font=body_font, fill=text_fill, anchor='lm')
    return w, h


def trim_window_frame(img: Image.Image) -> Image.Image:
    rgb = img.convert('RGB')
    px = rgb.load()
    min_x, min_y = rgb.width, rgb.height
    max_x, max_y = 0, 0
    for y in range(rgb.height):
        for x in range(rgb.width):
            r, g, b = px[x, y]
            if r > 18 or g > 18 or b > 18:
                min_x = min(min_x, x)
                min_y = min(min_y, y)
                max_x = max(max_x, x)
                max_y = max(max_y, y)
    if max_x <= min_x or max_y <= min_y:
        return img
    pad = 6
    return img.crop((max(min_x - pad, 0), max(min_y - pad, 0), min(max_x + pad, img.width), min(max_y + pad, img.height)))


def sanitize_shot(img: Image.Image, is_dark: bool) -> Image.Image:
    shot = trim_window_frame(img).convert('RGBA').copy()
    d = ImageDraw.Draw(shot)
    fill = (236, 239, 244, 255) if not is_dark else (73, 87, 120, 255)
    stroke = (198, 210, 226, 255) if not is_dark else (99, 113, 150, 255)
    d.rounded_rectangle((86, 780, 228, 840), radius=12, fill=fill, outline=stroke, width=1)
    return shot


def mock_rename_shot(img: Image.Image, locale: str, is_dark: bool) -> Image.Image:
    shot = sanitize_shot(img, is_dark)
    draw = ImageDraw.Draw(shot)
    title_font = font(CN_TITLE_FONT if locale == 'zh-Hans' else EN_TITLE_FONT, 26)
    body_font = font(CN_BODY_FONT if locale == 'zh-Hans' else EN_BODY_FONT, 16)
    note_font = font(CN_BODY_FONT if locale == 'zh-Hans' else EN_BODY_FONT, 14)
    mono_font = font(MONO_FONT, 15)

    panel = (24, 474, shot.width - 22, shot.height - 22)
    fill = (60, 82, 117, 245) if is_dark else (244, 247, 252, 248)
    stroke = (106, 128, 170, 255) if is_dark else (201, 214, 234, 255)
    text_fill = (243, 247, 252) if is_dark else (28, 39, 56)
    sub_fill = (194, 205, 222) if is_dark else (93, 108, 130)
    accent = (104, 168, 255) if is_dark else (61, 125, 233)
    field_fill = (71, 90, 124, 255) if is_dark else (230, 236, 246, 255)

    draw.rounded_rectangle(panel, radius=20, fill=fill, outline=stroke, width=2)
    x1, y1, x2, y2 = panel
    cursor_y = y1 + 24
    title = '4) Ask and Rename' if locale == 'en-US' else '4) 询问并重命名'
    draw.text((x1 + 20, cursor_y), title, font=title_font, fill=text_fill)
    cursor_y += 40

    suggested_label = 'Suggested file name' if locale == 'en-US' else '建议文件名'
    file_name = (
        'Introduction to Distributed Algorithms - Gerard Tel - 2001.pdf'
        if locale == 'en-US'
        else 'Introduction to Algorithms, fourth edition - Cormen.pdf'
    )
    editable_label = 'Final file name (editable)' if locale == 'en-US' else '最终文件名（可编辑）'
    helper = (
        'Rename uses the latest written metadata. You can still adjust the final file name before applying it.'
        if locale == 'en-US'
        else '重命名会基于最新写入的元数据，同时保留最后一次手动修改文件名的能力。'
    )
    primary = 'Rename' if locale == 'en-US' else '确认重命名'
    secondary = 'Skip' if locale == 'en-US' else '跳过'

    draw.text((x1 + 20, cursor_y), suggested_label, font=note_font, fill=sub_fill)
    cursor_y += 22
    draw.text((x1 + 20, cursor_y), file_name, font=body_font, fill=text_fill)
    cursor_y += 40
    draw.text((x1 + 20, cursor_y), editable_label, font=note_font, fill=sub_fill)
    cursor_y += 24
    field_h = 40
    field_rect = (x1 + 20, cursor_y, x2 - 20, cursor_y + field_h)
    draw.rounded_rectangle(field_rect, radius=10, fill=field_fill, outline=stroke, width=1)
    draw.text((field_rect[0] + 14, field_rect[1] + field_h / 2), file_name, font=mono_font, fill=text_fill, anchor='lm')
    cursor_y += field_h + 18

    helper_text = wrap_text(draw, helper, note_font, x2 - x1 - 40, spacing=5)
    draw.multiline_text((x1 + 20, cursor_y), helper_text, font=note_font, fill=sub_fill, spacing=5)
    helper_box = draw.multiline_textbbox((x1 + 20, cursor_y), helper_text, font=note_font, spacing=5)
    cursor_y = helper_box[3] + 18

    btn_h = 38
    secondary_w = 82 if locale == 'en-US' else 90
    primary_w = 104 if locale == 'en-US' else 124
    secondary_rect = (x2 - 20 - secondary_w - primary_w - 14, cursor_y, x2 - 20 - primary_w - 14, cursor_y + btn_h)
    primary_rect = (x2 - 20 - primary_w, cursor_y, x2 - 20, cursor_y + btn_h)
    draw.rounded_rectangle(secondary_rect, radius=10, fill=(36, 48, 74, 255) if is_dark else (236, 241, 248, 255), outline=stroke, width=1)
    draw.rounded_rectangle(primary_rect, radius=10, fill=accent, outline=accent, width=1)
    draw.text(((secondary_rect[0] + secondary_rect[2]) / 2, (secondary_rect[1] + secondary_rect[3]) / 2), secondary, font=body_font, fill=text_fill, anchor='mm')
    draw.text(((primary_rect[0] + primary_rect[2]) / 2, (primary_rect[1] + primary_rect[3]) / 2), primary, font=body_font, fill=(255, 255, 255), anchor='mm')
    return shot


def screenshot_panel(shot: Image.Image, is_dark: bool) -> Image.Image:
    frame_pad = 28
    shot = sanitize_shot(shot, is_dark)
    shot = fit_image(shot, 1460, 1040)
    shot = rounded(shot, 34)
    panel = Image.new('RGBA', (shot.width + frame_pad * 2, shot.height + frame_pad * 2), (0, 0, 0, 0))
    d = ImageDraw.Draw(panel)
    fill = (255, 255, 255, 216) if not is_dark else (18, 26, 48, 232)
    stroke = (199, 214, 232, 255) if not is_dark else (76, 96, 136, 255)
    d.rounded_rectangle((0, 0, panel.width - 1, panel.height - 1), radius=44, fill=fill, outline=stroke, width=2)
    panel.alpha_composite(shot, (frame_pad, frame_pad))
    return panel


def draw_text_card(canvas: Image.Image, locale: str, cfg: dict, is_dark: bool, preview: bool = False):
    draw = ImageDraw.Draw(canvas)
    if locale == 'zh-Hans':
        title_font = font(CN_TITLE_FONT, 56 if preview else 88)
        sub_font = font(CN_BODY_FONT, 27 if preview else 39)
        body_font = font(CN_BODY_FONT, 23 if preview else 29)
        eyebrow_font = font(CN_BODY_FONT, 22 if preview else 24)
    else:
        title_font = font(EN_TITLE_FONT, 62 if preview else 96)
        sub_font = font(EN_BODY_FONT, 27 if preview else 39)
        body_font = font(EN_BODY_FONT, 23 if preview else 29)
        eyebrow_font = font(EN_BODY_FONT, 22 if preview else 24)
    brand_font = font(EN_TITLE_FONT, 44 if preview else 50)

    card_x, card_y = (74, 76) if preview else (112, 96)
    card_w, card_h = (720, 930) if preview else (1010, 1520)
    layer = Image.new('RGBA', canvas.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    fill = (255, 255, 255, 192) if not is_dark else (11, 19, 40, 184)
    stroke = (216, 226, 238, 255) if not is_dark else (84, 100, 138, 255)
    d.rounded_rectangle((card_x, card_y, card_x + card_w, card_y + card_h), radius=44, fill=fill, outline=stroke, width=2)
    canvas.alpha_composite(layer)

    logo = Image.open(LOGO).convert('RGBA').resize((94 if preview else 102, 94 if preview else 102), Image.Resampling.LANCZOS)
    canvas.alpha_composite(logo, (card_x + 50, card_y + 48))
    text_fill = (27, 36, 51) if not is_dark else (244, 247, 252)
    sub_fill = (82, 95, 116) if not is_dark else (195, 207, 226)
    accent = (74, 113, 202) if not is_dark else (118, 167, 255)

    draw.text((card_x + 176, card_y + 60), 'PDF Librarian', font=brand_font, fill=text_fill)
    chip(draw, (card_x + 50, card_y + 170), cfg['eyebrow'], eyebrow_font,
         fill=(231, 238, 251, 255) if not is_dark else (34, 52, 88, 255),
         stroke=(196, 213, 239, 255) if not is_dark else (78, 104, 152, 255),
         text_fill=accent)

    title_text = wrap_text(draw, cfg['title'], title_font, 820 if not preview else 560, spacing=10 if locale == 'zh-Hans' else 12)
    title_y = card_y + (256 if not preview else 228)
    draw.multiline_text((card_x + 50, title_y), title_text, font=title_font, fill=text_fill, spacing=10 if locale == 'zh-Hans' else 12)
    title_box = draw.multiline_textbbox((card_x + 50, title_y), title_text, font=title_font, spacing=10 if locale == 'zh-Hans' else 12)

    sub_text = wrap_text(draw, cfg['subtitle'], sub_font, 840 if not preview else 570, spacing=8)
    sub_y = title_box[3] + 24
    draw.multiline_text((card_x + 50, sub_y), sub_text, font=sub_font, fill=sub_fill, spacing=8)
    sub_box = draw.multiline_textbbox((card_x + 50, sub_y), sub_text, font=sub_font, spacing=8)

    points_y = sub_box[3] + (54 if not preview else 42)
    step = 78 if not preview else 68
    for idx, point in enumerate(cfg['points'], start=1):
        dot_x = card_x + 54
        dot_y = points_y + (idx - 1) * step
        draw.ellipse((dot_x, dot_y + 4, dot_x + 16, dot_y + 20), fill=accent)
        point_text = wrap_text(draw, point, body_font, 760 if not preview else 510, spacing=6)
        draw.multiline_text((dot_x + 36, dot_y), point_text, font=body_font, fill=text_fill, spacing=6)

    if not preview:
        footer_y = card_y + card_h - 110
        footer_items = ['macOS 13+', 'V1.0.0', 'Dublin Core']
        fx = card_x + 50
        for item in footer_items:
            w, _ = chip(draw, (fx, footer_y), item, eyebrow_font,
                        fill=(255, 255, 255, 220) if not is_dark else (28, 40, 68, 255),
                        stroke=(207, 219, 236, 255) if not is_dark else (78, 100, 142, 255),
                        text_fill=text_fill if not is_dark else (224, 233, 245))
            fx += w + 14


def load_slide_image(locale: str, cfg: dict, is_dark: bool) -> Image.Image:
    img = Image.open(cfg['image'])
    if cfg.get('mock') == 'rename':
        return mock_rename_shot(img, locale, is_dark)
    return img


def make_slide(locale: str, idx: int, cfg: dict):
    is_dark = cfg['theme'] == 'dark'
    if not is_dark:
        bg = gradient((W, H), (249, 251, 255), (216, 229, 246))
        glow_a = (104, 149, 255, 82)
        glow_b = (38, 167, 255, 66)
    else:
        bg = gradient((W, H), (9, 18, 42), (3, 10, 28))
        glow_a = (98, 136, 255, 118)
        glow_b = (18, 170, 255, 92)
    canvas = bg.convert('RGBA')
    add_glow(canvas, (-260, -120, 960, 760), glow_a, 180)
    add_glow(canvas, (1400, 860, 3180, 2140), glow_b, 220)

    draw_text_card(canvas, locale, cfg, is_dark, preview=False)

    shot = load_slide_image(locale, cfg, is_dark)
    panel = screenshot_panel(shot, is_dark)
    shadow = Image.new('RGBA', canvas.size, (0, 0, 0, 0))
    sx, sy = 1230, 286
    sb = Image.new('RGBA', (panel.width + 84, panel.height + 84), (0, 0, 0, 0))
    sd = ImageDraw.Draw(sb)
    sd.rounded_rectangle((26, 26, panel.width + 28, panel.height + 28), radius=66, fill=(0, 0, 0, 72 if not is_dark else 128))
    sb = sb.filter(ImageFilter.GaussianBlur(24))
    shadow.alpha_composite(sb, (sx - 24, sy + 14))
    canvas.alpha_composite(shadow)
    canvas.alpha_composite(panel, (sx, sy))

    out_dir = SCREEN_OUT / locale
    out_dir.mkdir(parents=True, exist_ok=True)
    out_path = out_dir / f'{idx:02d}.png'
    canvas.convert('RGB').save(out_path, quality=95)
    return out_path


def make_preview(locale: str):
    cfg = PREVIEWS[locale]
    bg = gradient((PW, PH), (248, 251, 255), (215, 228, 244))
    canvas = bg.convert('RGBA')
    add_glow(canvas, (-120, -80, 640, 420), (90, 139, 248, 82), 128)
    add_glow(canvas, (1080, 540, 2040, 1240), (22, 164, 255, 72), 160)

    draw_text_card(canvas, locale, cfg, is_dark=False, preview=True)

    light_locale = 'en' if locale == 'en-US' else 'zh-Hans'
    light = screenshot_panel(Image.open(ASSETS / f'pdflibrarian-{light_locale}-light-full.png'), False)
    dark_source = RAW / ('en-edit-dark.png' if locale == 'en-US' else 'zh-edit-dark.png')
    dark = screenshot_panel(mock_rename_shot(Image.open(dark_source), locale, True), True)
    light = fit_image(light, 900, 590)
    dark = fit_image(dark, 900, 590)

    def paste_panel(panel: Image.Image, pos: tuple[int, int], shadow_alpha: int):
        sh = Image.new('RGBA', canvas.size, (0, 0, 0, 0))
        box = Image.new('RGBA', (panel.width + 54, panel.height + 54), (0, 0, 0, 0))
        dd = ImageDraw.Draw(box)
        dd.rounded_rectangle((18, 18, panel.width + 18, panel.height + 18), radius=54, fill=(0, 0, 0, shadow_alpha))
        box = box.filter(ImageFilter.GaussianBlur(18))
        sh.alpha_composite(box, (pos[0] - 12, pos[1] + 4))
        canvas.alpha_composite(sh)
        canvas.alpha_composite(panel, pos)

    paste_panel(light, (980, 132), 68)
    paste_panel(dark, (1120, 430), 92)

    out_dir = PREVIEW_OUT
    out_dir.mkdir(parents=True, exist_ok=True)
    out_path = out_dir / f'preview-{locale}.png'
    canvas.convert('RGB').save(out_path, quality=95)
    return out_path


def main():
    generated = []
    for locale, slides in SLIDES.items():
        for idx, cfg in enumerate(slides, start=1):
            generated.append(make_slide(locale, idx, cfg))
    for locale in PREVIEWS:
        generated.append(make_preview(locale))
    for path in generated:
        print(path)


if __name__ == '__main__':
    main()
