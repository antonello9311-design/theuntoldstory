# Velo · correzione della variabile SQL

Il tentativo precedente ha restituito 42702 e la transazione ha lasciato invariata la riga. La nuova coppia Source e Recovery usa la costante locale v_velo_technique_id e conserva la colonna qualificata a.technique_id nella guardia.

Otto riferimenti rinominati per file. Ripristinando il nome originale, entrambe le copie coincidono byte per byte con i sorgenti canonici. Source e Recovery sono inverse esatte rispetto alle impronte della riga e ai soli valori di uso.

Analizzati tutti gli statement in entrambe le versioni, inclusi i blocchi PL/pgSQL. Il controllo verifica la grammatica e il predicato. Rimangono la revisione indipendente e il preflight sullo schema vivo.

- VELO_METADATA_SOURCE.sql · SHA-256 9a6cc39d154f80b320311308eaddbde3eab45b00a01422145ecf92acedd1abb9
- VELO_METADATA_RECOVERY.sql · SHA-256 4ad501df9d62941af37269b3b5f9ad5301f582a473c70392d1657e1988b67b2f
