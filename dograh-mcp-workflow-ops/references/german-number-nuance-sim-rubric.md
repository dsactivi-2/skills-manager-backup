# German numbers_spoken_ok — nuanced rubric

Do **not** score "all numbers as words".

Pass when:
- Preise/Mengen/Jahre/% as Zahlwort (neunundvierzig Euro)
- PLZ/Telefon/Hausnr./IDs as Zifferngruppen (null vier drei drei fünf)

Fail when:
- PLZ/phone read as one huge number-word (04335 → viertausend…)
- Prices read digit-by-digit without need

Lesson: Aquaphor #8783 Sim R2 naturalness −1.0 after absolute Zahlwort fix.
