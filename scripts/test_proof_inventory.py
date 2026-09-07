import unittest
from proof_inventory import code_only

class LeanLexing(unittest.TestCase):
    def test_nested_comments_and_strings(self):
        source = '/- sorry /- admit -/ sorry -/\ntheorem t : True := by\n  trivial -- sorry\n#check "sorry \\" admit"\n'
        code = code_only(source)
        self.assertEqual(len(source), len(code))
        self.assertEqual(source.count('\n'), code.count('\n'))
        self.assertNotIn('sorry', code)
        self.assertNotIn('admit', code)
        self.assertIn('trivial', code)

    def test_real_hole_survives_inline_comment(self):
        self.assertIn('sorry', code_only('theorem t : False := by sorry -- no sorry'))

    def test_unterminated_comment(self):
        with self.assertRaises(ValueError): code_only('/- unfinished')

if __name__ == '__main__': unittest.main()
