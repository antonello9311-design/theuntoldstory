"""Static SQL inventory only. Never executes SQL or certifies semantic safety.
Quoted catalog definitions are scalar data, not executable statements.
DO/function bodies and dynamic SQL require independent semantic review.
"""
import argparse
import hashlib
import json
from pathlib import Path
from pglast import ast, parse_sql, parse_plpgsql


def inspect_source(source):
    trees = parse_sql(source)
    statements = []
    for index, raw in enumerate(trees, 1):
        node = raw.stmt
        item = {'index': index, 'node': type(node).__name__, 'offset': raw.stmt_location}
        # Report procedural containers explicitly. Do not scan literals for SQL keywords.
        if isinstance(node, ast.DoStmt):
            options = {d.defname: d.arg.sval for d in node.args if isinstance(d.arg, ast.String)}
            language = options.get('language', 'plpgsql')
            item['procedural_language'] = language
            if language == 'plpgsql':
                start = raw.stmt_location
                end = start + raw.stmt_len if raw.stmt_len else len(source)
                try:
                    parse_plpgsql(source[start:end])
                    item['procedural_grammar'] = 'PASS_GRAMMAR_ONLY'
                except Exception as error:
                    item['procedural_grammar'] = 'NOT_QUALIFIED'
                    item['diagnostic'] = str(error)
            item['semantic_review_required'] = True
        elif isinstance(node, ast.CreateFunctionStmt):
            item['function_body_semantics'] = 'NOT_EVALUATED'
            item['semantic_review_required'] = True
        statements.append(item)
    return {'sha256': hashlib.sha256(source.encode()).hexdigest(),
            'sql_grammar': 'PASS_GRAMMAR_ONLY', 'statement_count': len(trees),
            'statements': statements, 'semantics': 'NOT_QUALIFIED',
            'execution': 'NOT_RUN', 'production_eligibility': False}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('source', type=Path)
    args = parser.parse_args()
    print(json.dumps(inspect_source(args.source.read_text()), indent=2, ensure_ascii=False))


if __name__ == '__main__':
    main()
