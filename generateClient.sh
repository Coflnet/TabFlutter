docker run --rm -v "${PWD}:/local" --network host -u $(id -u ${USER}):$(id -g ${USER})  openapitools/openapi-generator-cli generate \
 -i https://tab.coflnet.com/api/openapi/v1/openapi.json \
 -g dart -o /local/lib/gAll 

rm -rf lib/generatedCode
cp -r lib/gAll/lib lib/generatedCode
rm -rf lib/gAll