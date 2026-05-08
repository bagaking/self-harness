#!/usr/bin/env python3
"""
Quick validation script for skills - minimal version
"""

import re
import sys
from pathlib import Path

try:
    import yaml
except ModuleNotFoundError:
    yaml = None

MAX_SKILL_NAME_LENGTH = 64


class FrontmatterError(ValueError):
    """Raised when SKILL.md frontmatter cannot be parsed."""


def parse_simple_frontmatter(frontmatter_text):
    """Parse the simple YAML mappings used by repository SKILL.md files."""
    frontmatter = {}
    current_map = None

    for line_number, raw_line in enumerate(frontmatter_text.splitlines(), start=1):
        line = raw_line.strip()
        if not line or line.startswith("#"):
            continue
        indent = len(raw_line) - len(raw_line.lstrip(" "))

        if indent == 0:
            current_map = None
            target = frontmatter
        elif indent == 2:
            if current_map is None:
                raise FrontmatterError(
                    "PyYAML is unavailable and the fallback parser only supports "
                    f"one-level nested mappings (line {line_number})"
                )
            target = current_map
        else:
            raise FrontmatterError(
                "PyYAML is unavailable and the fallback parser only supports "
                f"top-level scalars and one-level nested mappings (line {line_number})"
            )

        if line.startswith("-"):
            raise FrontmatterError(
                "PyYAML is unavailable and the fallback parser does not support "
                f"sequences (line {line_number})"
            )
        if ":" not in line:
            raise FrontmatterError(f"Invalid frontmatter line {line_number}: missing ':'")

        key, value = line.split(":", 1)
        key = key.strip()
        value = value.strip()
        if not key:
            raise FrontmatterError(f"Invalid frontmatter line {line_number}: empty key")
        if not value and indent == 0:
            frontmatter[key] = {}
            current_map = frontmatter[key]
            continue
        if not value:
            raise FrontmatterError(
                "PyYAML is unavailable and the fallback parser does not support "
                f"nested or multiline values (line {line_number})"
            )

        target[key] = parse_simple_scalar(value, line_number)

    return frontmatter


def parse_simple_scalar(value, line_number):
    """Parse a conservative subset of YAML scalar values."""
    if value[0] in "\"'":
        quote = value[0]
        if len(value) < 2 or value[-1] != quote:
            raise FrontmatterError(f"Invalid quoted scalar on line {line_number}")
        return value[1:-1]

    if value[0] in "[]{}|>&*!":
        raise FrontmatterError(
            "PyYAML is unavailable and the fallback parser does not support "
            f"complex scalar values (line {line_number})"
        )

    lower_value = value.lower()
    if lower_value in {"true", "false"}:
        return lower_value == "true"
    if lower_value in {"null", "~"}:
        return None
    if re.match(r"^[+-]?\d+$", value):
        return int(value)
    if re.match(r"^[+-]?\d+\.\d+$", value):
        return float(value)

    return value


def load_frontmatter(frontmatter_text):
    """Load frontmatter with PyYAML when available, otherwise use a local fallback."""
    if yaml is not None:
        try:
            return yaml.safe_load(frontmatter_text)
        except yaml.YAMLError as e:
            raise FrontmatterError(e) from e

    return parse_simple_frontmatter(frontmatter_text)


def validate_skill(skill_path):
    """Basic validation of a skill"""
    skill_path = Path(skill_path)

    skill_md = skill_path / "SKILL.md"
    if not skill_md.exists():
        return False, "SKILL.md not found"

    content = skill_md.read_text()
    if not content.startswith("---"):
        return False, "No YAML frontmatter found"

    match = re.match(r"^---\n(.*?)\n---", content, re.DOTALL)
    if not match:
        return False, "Invalid frontmatter format"

    frontmatter_text = match.group(1)

    try:
        frontmatter = load_frontmatter(frontmatter_text)
        if not isinstance(frontmatter, dict):
            return False, "Frontmatter must be a YAML dictionary"
    except FrontmatterError as e:
        return False, f"Invalid YAML in frontmatter: {e}"

    allowed_properties = {"name", "description", "license", "allowed-tools", "metadata"}

    unexpected_keys = set(frontmatter.keys()) - allowed_properties
    if unexpected_keys:
        allowed = ", ".join(sorted(allowed_properties))
        unexpected = ", ".join(sorted(unexpected_keys))
        return (
            False,
            f"Unexpected key(s) in SKILL.md frontmatter: {unexpected}. Allowed properties are: {allowed}",
        )

    if "name" not in frontmatter:
        return False, "Missing 'name' in frontmatter"
    if "description" not in frontmatter:
        return False, "Missing 'description' in frontmatter"

    name = frontmatter.get("name", "")
    if not isinstance(name, str):
        return False, f"Name must be a string, got {type(name).__name__}"
    name = name.strip()
    if name:
        if not re.match(r"^[a-z0-9-]+$", name):
            return (
                False,
                f"Name '{name}' should be hyphen-case (lowercase letters, digits, and hyphens only)",
            )
        if name.startswith("-") or name.endswith("-") or "--" in name:
            return (
                False,
                f"Name '{name}' cannot start/end with hyphen or contain consecutive hyphens",
            )
        if len(name) > MAX_SKILL_NAME_LENGTH:
            return (
                False,
                f"Name is too long ({len(name)} characters). "
                f"Maximum is {MAX_SKILL_NAME_LENGTH} characters.",
            )

    description = frontmatter.get("description", "")
    if not isinstance(description, str):
        return False, f"Description must be a string, got {type(description).__name__}"
    description = description.strip()
    if description:
        if "<" in description or ">" in description:
            return False, "Description cannot contain angle brackets (< or >)"
        if len(description) > 1024:
            return (
                False,
                f"Description is too long ({len(description)} characters). Maximum is 1024 characters.",
            )

    return True, "Skill is valid!"


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python quick_validate.py <skill_directory>")
        sys.exit(1)

    valid, message = validate_skill(sys.argv[1])
    print(message)
    sys.exit(0 if valid else 1)
