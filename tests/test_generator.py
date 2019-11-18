import unittest

from buzz import generator


class TestMethod(unittest.TestCase):

    def test_sample_single_word(self):
        test = ('alef', 'bet', 'gimel')
        word = generator.sample(test)
        assert word in test

    def test_sample_multiple_words(self):
        test = ('alpha', 'beta', 'gamma')
        words = generator.sample(test, 2)
        assert len(words) == 2
        assert words[0] in test
        assert words[1] in test
        assert words[0] is not words[1]

    def test_generate_buzz_of_at_least_five_words(self):
        self.phrase = generator.generate_buzz()
        assert len(self.phrase.split()) >= 5


if __name__ == '__main__':
    unittest.main()
