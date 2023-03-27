pm.test("Content-Type is present", function () {
    pm.response.to.have.header("Content-Type");
});
pm.test("Response has text", function () {
    var jsonData = pm.response.json();
    pm.expect(jsonData.json.text).to.include('');
});