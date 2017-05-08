# redis overhead

Measures the overhead of redis w.r.t raw memory bandwidth throughput.

To run this experiment on CloudLab:

```bash
popper check \
  -e CLOUDLAB_USER=user \
  -e CLOUDLAB_PASSWD='pwd' \
  -e CLOUDLAB_CERT_PATH=`pwd`/yourcloudlab.pem \
  -e CLOUDLAB_KEY_PATH=`pwd`/your_rsa.pub \
  -e CLOUDLAB_PROJECT=yourproject
  -e MYSSHKEY=`pwd`/your_key_on_cloudlab_nodes
```
