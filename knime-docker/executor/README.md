# knime/knime (official executor image)

Runs the official `knime/knime:r-5.11.0-642` image (KNIME Analytics Platform 5.11.0 executor) as a long-lived container.
The parent folder's `workspace/` and `data/` are mounted at `/home/knime/workspace` and `/home/knime/data`.

```bash
docker compose up -d                 # start
docker exec -it knime-executor bash  # shell inside; KNIME is at /home/knime/knime/knime
docker compose down                  # stop
```

Notes:
- This image is headless (no GUI). It is built for KNIME Business Hub execution contexts. For the desktop GUI, use the noVNC setup in the parent folder.
- It is amd64-only, so it runs under emulation on Apple Silicon.
- Running local workflows headlessly (`-application org.knime.product.KNIME_BATCH_APPLICATION`) fails with
  "KNIME Batch Executor is not installed". That extension isn't on KNIME's public update sites, so it can't be added here without a KNIME license.
