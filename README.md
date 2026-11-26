# IBM 6500 M07 study note

Han Mai's study note follows Yoyu Li's LinkedIn Learning course on BigQuery and Looker Studio. The certificate section is pending. The public files contain independent practice SQL and derived results from NOAA's public BigQuery data.

## Reproduce

With Quarto installed, run:

```sh
quarto render Han-Mai-M07-BigQuery-Looker-Studio.qmd
```

The standalone HTML embeds its resources. Open it in a browser. To reproduce the reported query results, open BigQuery Studio in a project permitted to query public US datasets. Run each statement in `temperature-exercises.sql` independently, checking the scan estimate first. The SQL uses public data and creates no cloud tables or views.
