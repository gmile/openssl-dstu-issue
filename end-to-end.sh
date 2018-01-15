echo "Cleaning up the mess..."
rm -r /tmp/workdir

echo "Extracting key and certs from pb_key.jks..."
jks-key-extractor /pb_key.jks $1 /tmp/workdir

echo "Converting extracted key from DER to PEM..."
/openssl-sandbox/openssl-dstu/apps/openssl pkey -in /tmp/workdir/key.der -inform DER -out /tmp/workdir/key.pem -engine dstu

echo "Looking for matching certificate..."
for cert in $(ls /tmp/workdir/cert*.der)
do
  out=$(/openssl-sandbox/openssl-dstu/apps/openssl x509 -in $cert -inform der -noout -text -nameopt oneline,utf8,-esc_msb)
  matched_lines=$(echo $out | grep -e 'Digital Signature' -c)

  if [ "$matched_lines" -eq "1" ]
  then
    echo "Found matching cert is: $cert"
    echo "Converting $cert from DER to PEM..."
    /openssl-sandbox/openssl-dstu/apps/openssl x509 -inform DER -outform PEM -in $cert -out /tmp/workdir/signer.pem
  fi
done

echo "Creating a sample message..."
echo "Hello, world!" > /tmp/workdir/message.txt

echo "Attempting to sign the message..."
gdb --args /openssl-sandbox/openssl-dstu/apps/openssl smime \
  -sign \
  -in /tmp/workdir/message.txt \
  -out /tmp/workdir/message.txt.signed \
  -signer /tmp/workdir/signer.pem \
  -inkey /tmp/workdir/key.pem \
  -text
