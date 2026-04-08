#!/usr/bin/env python3
"""
Patent Submission PPTX Generator

Generates PowerPoint presentations from patent submission JSON files,
following the ViewSonic patent submission template structure.

Usage:
    python generate-pptx.py <input.json> [output.pptx]

Requirements:
    pip install python-pptx
"""

import json
import sys
from pathlib import Path

try:
    from pptx import Presentation
    from pptx.util import Inches, Pt
    from pptx.dml.color import RGBColor
    from pptx.enum.text import PP_ALIGN, MSO_ANCHOR
    from pptx.enum.shapes import MSO_SHAPE
except ImportError:
    print("Error: python-pptx is required")
    print("Install with: pip install python-pptx")
    sys.exit(1)


# =============================================================================
# ViewSonic Theme Colors
# =============================================================================

VS_BLUE = RGBColor(0, 82, 147)        # #005293 - Primary brand color
VS_LIGHT_BLUE = RGBColor(0, 120, 212)  # #0078D4 - Accent
VS_DARK_BLUE = RGBColor(0, 51, 102)    # #003366 - Dark variant
VS_GRAY = RGBColor(88, 89, 91)         # #585B5B - Body text
VS_LIGHT_GRAY = RGBColor(245, 245, 245)  # #F5F5F5 - Background
VS_WHITE = RGBColor(255, 255, 255)     # #FFFFFF
VS_BLACK = RGBColor(0, 0, 0)           # #000000


# =============================================================================
# Font Settings
# =============================================================================

FONT_ZH = "Microsoft JhengHei"  # 微軟正黑體
FONT_EN = "Calibri"
FONT_MONO = "Consolas"

# Fallback fonts for different platforms
FONT_ZH_FALLBACK = ["PingFang TC", "Noto Sans CJK TC", "SimHei"]


# =============================================================================
# Slide Dimensions (16:9)
# =============================================================================

SLIDE_WIDTH = Inches(13.333)
SLIDE_HEIGHT = Inches(7.5)
MARGIN = Inches(0.5)
TITLE_TOP = Inches(0.5)
CONTENT_TOP = Inches(1.5)


# =============================================================================
# Helper Functions
# =============================================================================

def set_font(run, font_name=FONT_ZH, size=18, bold=False, color=VS_GRAY):
    """Set font properties for a text run."""
    run.font.name = font_name
    run.font.size = Pt(size)
    run.font.bold = bold
    run.font.color.rgb = color


def add_title_shape(slide, text, top=TITLE_TOP, font_size=32):
    """Add a title text box to a slide."""
    left = MARGIN
    width = SLIDE_WIDTH - (2 * MARGIN)
    height = Inches(0.8)

    shape = slide.shapes.add_textbox(left, top, width, height)
    tf = shape.text_frame
    tf.word_wrap = True

    p = tf.paragraphs[0]
    p.text = text
    p.alignment = PP_ALIGN.LEFT
    set_font(p.runs[0], FONT_ZH, font_size, bold=True, color=VS_BLUE)

    return shape


def add_content_box(slide, top=CONTENT_TOP, height=Inches(5.5)):
    """Add a content text box to a slide."""
    left = MARGIN
    width = SLIDE_WIDTH - (2 * MARGIN)

    shape = slide.shapes.add_textbox(left, top, width, height)
    tf = shape.text_frame
    tf.word_wrap = True

    return shape


def add_bullet_points(text_frame, bullets, font_size=16):
    """Add bullet points to a text frame."""
    for i, bullet in enumerate(bullets):
        if i == 0:
            p = text_frame.paragraphs[0]
        else:
            p = text_frame.add_paragraph()

        # Handle both string and dict formats
        if isinstance(bullet, dict):
            # Prefer Chinese text, fall back to English
            bullet_text = bullet.get('text_zh') or bullet.get('text') or bullet.get('summary_zh') or bullet.get('summary') or str(bullet)
        else:
            bullet_text = str(bullet)

        p.text = f"• {bullet_text}"
        p.alignment = PP_ALIGN.LEFT
        p.space_before = Pt(6)
        p.space_after = Pt(6)

        if p.runs:
            set_font(p.runs[0], FONT_ZH, font_size, color=VS_GRAY)


def add_subtitle(text_frame, text, font_size=14):
    """Add a subtitle/annotation to a text frame."""
    p = text_frame.add_paragraph()
    p.text = text
    p.alignment = PP_ALIGN.LEFT
    p.space_before = Pt(12)

    if p.runs:
        set_font(p.runs[0], FONT_EN, font_size, color=VS_LIGHT_BLUE)


# =============================================================================
# Slide Generators
# =============================================================================

def create_title_slide(prs, data):
    """Create the title slide (Slide 1)."""
    slide_layout = prs.slide_layouts[6]  # Blank layout
    slide = prs.slides.add_slide(slide_layout)

    # Background color bar at top
    shape = slide.shapes.add_shape(
        MSO_SHAPE.RECTANGLE,
        Inches(0), Inches(0),
        SLIDE_WIDTH, Inches(2.5)
    )
    shape.fill.solid()
    shape.fill.fore_color.rgb = VS_BLUE
    shape.line.fill.background()

    # Chinese title
    title_zh = data.get('title_zh', data.get('metadata', {}).get('title_zh', '專利標題'))
    left = MARGIN
    top = Inches(2.8)
    width = SLIDE_WIDTH - (2 * MARGIN)
    height = Inches(1.2)

    shape = slide.shapes.add_textbox(left, top, width, height)
    tf = shape.text_frame
    p = tf.paragraphs[0]
    p.text = title_zh
    p.alignment = PP_ALIGN.CENTER
    set_font(p.runs[0], FONT_ZH, 44, bold=True, color=VS_BLUE)

    # English title
    title_en = data.get('title_en', data.get('metadata', {}).get('title_en', 'Patent Title'))
    top = Inches(4.2)
    height = Inches(0.8)

    shape = slide.shapes.add_textbox(left, top, width, height)
    tf = shape.text_frame
    p = tf.paragraphs[0]
    p.text = f"({title_en})"
    p.alignment = PP_ALIGN.CENTER
    set_font(p.runs[0], FONT_EN, 24, color=VS_GRAY)

    # Patent ID and date (footer)
    patent_id = data.get('patent_id', data.get('metadata', {}).get('patent_id', ''))
    date = data.get('date', data.get('metadata', {}).get('date', ''))

    if patent_id or date:
        top = Inches(6.5)
        shape = slide.shapes.add_textbox(left, top, width, Inches(0.4))
        tf = shape.text_frame
        p = tf.paragraphs[0]
        p.text = f"{patent_id}  |  {date}" if patent_id and date else (patent_id or date)
        p.alignment = PP_ALIGN.CENTER
        set_font(p.runs[0], FONT_EN, 12, color=VS_GRAY)

    return slide


def create_problem_slide(prs, data):
    """Create the problem statement slide (Slide 2)."""
    slide_layout = prs.slide_layouts[6]
    slide = prs.slides.add_slide(slide_layout)

    # Title
    add_title_shape(slide, "本發明要解決的問題")

    # Subtitle annotation
    subtitle_shape = slide.shapes.add_textbox(
        SLIDE_WIDTH - Inches(3.5), TITLE_TOP + Inches(0.1),
        Inches(3), Inches(0.4)
    )
    tf = subtitle_shape.text_frame
    p = tf.paragraphs[0]
    p.text = "Background"
    p.alignment = PP_ALIGN.RIGHT
    set_font(p.runs[0], FONT_EN, 14, color=VS_LIGHT_BLUE)

    # Content
    content_shape = add_content_box(slide)
    tf = content_shape.text_frame

    bullets = data.get('bullets', data.get('content', {}).get('bullets', []))
    if bullets:
        add_bullet_points(tf, bullets)
    else:
        # Use description if no bullets
        desc = data.get('description', '')
        if desc:
            p = tf.paragraphs[0]
            p.text = desc
            set_font(p.runs[0], FONT_ZH, 16, color=VS_GRAY)

    return slide


def create_solution_slide(prs, data):
    """Create the solution slide (Slide 3)."""
    slide_layout = prs.slide_layouts[6]
    slide = prs.slides.add_slide(slide_layout)

    # Title
    add_title_shape(slide, "本發明提出的解決方案")

    # Subtitle
    subtitle_shape = slide.shapes.add_textbox(
        SLIDE_WIDTH - Inches(3.5), TITLE_TOP + Inches(0.1),
        Inches(3), Inches(0.4)
    )
    tf = subtitle_shape.text_frame
    p = tf.paragraphs[0]
    p.text = "Invention"
    p.alignment = PP_ALIGN.RIGHT
    set_font(p.runs[0], FONT_EN, 14, color=VS_LIGHT_BLUE)

    # Content
    content_shape = add_content_box(slide)
    tf = content_shape.text_frame

    # Overview paragraph
    overview = data.get('overview', '')
    if overview:
        p = tf.paragraphs[0]
        p.text = overview
        p.space_after = Pt(12)
        set_font(p.runs[0], FONT_ZH, 16, color=VS_GRAY)

    # Bullet points
    bullets = data.get('bullets', data.get('content', {}).get('bullets', []))
    # Also check key_innovations for solution slides
    key_innovations = data.get('key_innovations', data.get('content', {}).get('key_innovations', []))
    items = bullets or key_innovations

    if items:
        for item in items:
            p = tf.add_paragraph()
            # Handle both string and dict formats
            if isinstance(item, dict):
                item_text = item.get('title_zh') or item.get('title') or item.get('text_zh') or item.get('text') or str(item)
            else:
                item_text = str(item)
            p.text = f"• {item_text}"
            p.space_before = Pt(6)
            p.space_after = Pt(6)
            if p.runs:
                set_font(p.runs[0], FONT_ZH, 15, color=VS_GRAY)

    return slide


def create_algorithm_slide(prs, data):
    """Create the algorithm/flowchart slide (Slide 4)."""
    slide_layout = prs.slide_layouts[6]
    slide = prs.slides.add_slide(slide_layout)

    # Title
    title = data.get('title', '演算法流程圖')
    add_title_shape(slide, title)

    # Content - typically technical details or diagram description
    content_shape = add_content_box(slide)
    tf = content_shape.text_frame

    bullets = data.get('bullets', data.get('content', {}).get('bullets', []))
    if bullets:
        add_bullet_points(tf, bullets, font_size=14)

    # Diagram description placeholder
    diagram_desc = data.get('diagram_description', data.get('content', {}).get('diagram_description', ''))
    if diagram_desc:
        p = tf.add_paragraph()
        p.text = f"\n[圖表說明: {diagram_desc}]"
        p.space_before = Pt(12)
        if p.runs:
            set_font(p.runs[0], FONT_ZH, 12, color=VS_LIGHT_BLUE)

    return slide


def create_advantages_slide(prs, data):
    """Create the advantages slide (Slide 5)."""
    slide_layout = prs.slide_layouts[6]
    slide = prs.slides.add_slide(slide_layout)

    # Title
    add_title_shape(slide, "本發明的技術優勢")

    # Subtitle
    subtitle_shape = slide.shapes.add_textbox(
        SLIDE_WIDTH - Inches(4), TITLE_TOP + Inches(0.1),
        Inches(3.5), Inches(0.4)
    )
    tf = subtitle_shape.text_frame
    p = tf.paragraphs[0]
    p.text = "Advantage of the invention"
    p.alignment = PP_ALIGN.RIGHT
    set_font(p.runs[0], FONT_EN, 14, color=VS_LIGHT_BLUE)

    # Content
    content_shape = add_content_box(slide)
    tf = content_shape.text_frame

    bullets = data.get('bullets', data.get('content', {}).get('bullets', []))
    advantages = data.get('advantages', [])
    features = data.get('features', data.get('content', {}).get('features', []))

    items = bullets or advantages or features
    if items:
        for i, item in enumerate(items):
            if i == 0:
                p = tf.paragraphs[0]
            else:
                p = tf.add_paragraph()

            # Check if item has title and description (supports feature/feature_zh)
            if isinstance(item, dict):
                title = item.get('feature_zh') or item.get('feature') or item.get('title_zh') or item.get('title', '')
                desc = item.get('description', '') or item.get('benefit', '')
                p.text = f"• {title}："
                if p.runs:
                    set_font(p.runs[0], FONT_ZH, 16, bold=True, color=VS_BLUE)

                if desc:
                    p2 = tf.add_paragraph()
                    p2.text = f"  {desc}"
                    p2.space_after = Pt(8)
                    if p2.runs:
                        set_font(p2.runs[0], FONT_ZH, 14, color=VS_GRAY)
            else:
                p.text = f"• {item}"
                p.space_before = Pt(6)
                p.space_after = Pt(6)
                if p.runs:
                    set_font(p.runs[0], FONT_ZH, 15, color=VS_GRAY)

    return slide


def create_appendix_slide(prs, data):
    """Create the appendix slide (Slide 6)."""
    slide_layout = prs.slide_layouts[6]
    slide = prs.slides.add_slide(slide_layout)

    # Title - use Chinese title if available
    title = data.get('title_zh') or data.get('title', 'Appendix: 示意圖')
    add_title_shape(slide, title)

    # Content - claims summary or diagram references
    content_shape = add_content_box(slide)
    tf = content_shape.text_frame

    content = data.get('content', {})
    bullets = data.get('bullets', content.get('bullets', []))
    claims_summary = data.get('claims_summary', content.get('claims_summary', []))
    independent_claims = content.get('independent_claims', [])
    key_dependent_claims = content.get('key_dependent_claims', [])

    # Build items from various sources
    items = bullets or claims_summary
    if not items and independent_claims:
        items = []
        for claim in independent_claims:
            if isinstance(claim, dict):
                claim_text = f"Claim {claim.get('claim_number', '?')} ({claim.get('type', 'Method')}): {claim.get('summary_zh') or claim.get('summary', '')}"
            else:
                claim_text = str(claim)
            items.append(claim_text)

    if items:
        add_bullet_points(tf, items, font_size=14)

    return slide


def create_closing_slide(prs, data):
    """Create the closing slide (Slide 7)."""
    slide_layout = prs.slide_layouts[6]
    slide = prs.slides.add_slide(slide_layout)

    # Background
    shape = slide.shapes.add_shape(
        MSO_SHAPE.RECTANGLE,
        Inches(0), Inches(0),
        SLIDE_WIDTH, SLIDE_HEIGHT
    )
    shape.fill.solid()
    shape.fill.fore_color.rgb = VS_BLUE
    shape.line.fill.background()

    # Thank you text
    left = MARGIN
    top = Inches(3)
    width = SLIDE_WIDTH - (2 * MARGIN)
    height = Inches(1.5)

    shape = slide.shapes.add_textbox(left, top, width, height)
    tf = shape.text_frame
    p = tf.paragraphs[0]
    p.text = "Thank you."
    p.alignment = PP_ALIGN.CENTER
    set_font(p.runs[0], FONT_EN, 54, bold=True, color=VS_WHITE)

    # Optional: Contact or next steps
    contact = data.get('contact', data.get('content', {}).get('contact', ''))
    if contact:
        # Handle both string and dict formats for contact
        if isinstance(contact, dict):
            contact_text = contact.get('team', '') or contact.get('email', '') or contact.get('internal_reference', '')
        else:
            contact_text = str(contact)

        if contact_text:
            top = Inches(4.5)
            shape = slide.shapes.add_textbox(left, top, width, Inches(0.5))
            tf = shape.text_frame
            p = tf.paragraphs[0]
            p.text = contact_text
            p.alignment = PP_ALIGN.CENTER
            set_font(p.runs[0], FONT_EN, 14, color=VS_WHITE)

    return slide


# =============================================================================
# Main Generator
# =============================================================================

def generate_pptx(input_path: str, output_path: str = None):
    """Generate PPTX from submission JSON."""

    # Load JSON
    with open(input_path, 'r', encoding='utf-8') as f:
        data = json.load(f)

    # Determine output path
    if output_path is None:
        output_path = str(Path(input_path).with_suffix('.pptx'))

    # Create presentation
    prs = Presentation()
    prs.slide_width = SLIDE_WIDTH
    prs.slide_height = SLIDE_HEIGHT

    # Get slide data
    slides_data = data.get('slides', [])
    metadata = data.get('metadata', {})

    # Create slides based on type
    slide_creators = {
        'title': create_title_slide,
        'problem': create_problem_slide,
        'solution': create_solution_slide,
        'algorithm': create_algorithm_slide,
        'architecture': create_algorithm_slide,  # Alias
        'advantages': create_advantages_slide,
        'features': create_advantages_slide,     # Alias
        'appendix': create_appendix_slide,
        'claims': create_appendix_slide,         # Alias
        'closing': create_closing_slide,
    }

    if slides_data:
        # Use structured slide data
        for slide_data in slides_data:
            slide_type = slide_data.get('type', 'content')
            creator = slide_creators.get(slide_type)

            if creator:
                # Merge metadata into slide data for title slide
                if slide_type == 'title':
                    merged = {**metadata, **slide_data.get('content', {}), **slide_data}
                else:
                    merged = {**slide_data.get('content', {}), **slide_data}
                creator(prs, merged)
    else:
        # Create default 7-slide structure from metadata
        create_title_slide(prs, metadata)
        create_problem_slide(prs, data.get('problem', {}))
        create_solution_slide(prs, data.get('solution', {}))
        create_algorithm_slide(prs, data.get('algorithm', {}))
        create_advantages_slide(prs, data.get('advantages', {}))
        create_appendix_slide(prs, data.get('appendix', {}))
        create_closing_slide(prs, {})

    # Save
    prs.save(output_path)
    print(f"PPTX generated: {output_path}")

    return output_path


def main():
    if len(sys.argv) < 2:
        print("Usage: python generate-pptx.py <input.json> [output.pptx]")
        print("\nGenerates a PowerPoint presentation from patent submission JSON.")
        sys.exit(1)

    input_path = sys.argv[1]
    output_path = sys.argv[2] if len(sys.argv) > 2 else None

    if not Path(input_path).exists():
        print(f"Error: File not found: {input_path}")
        sys.exit(1)

    try:
        generate_pptx(input_path, output_path)
    except Exception as e:
        print(f"Error generating PPTX: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
