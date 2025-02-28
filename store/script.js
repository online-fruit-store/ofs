document.getElementById('uploadForm').addEventListener('submit', async function (event) {
    event.preventDefault();

    const fileInput = document.getElementById('fileInput');
    if (!fileInput.files.length) {
        alert('Please select a file.');
        return;
    }

    const formData = new FormData();
    formData.append('file', fileInput.files[0]);

    try {
        const response = await fetch('http://localhost:8000/upload', {
            method: 'POST',
            body: formData,
        });

        const result = await response.json();

        // Set the image source to the uploaded file's URL
        const imgElement = document.createElement('img');
        imgElement.src = result.url;
        imgElement.alt = 'Uploaded Image';
        imgElement.style.maxWidth = '300px';

        document.body.appendChild(imgElement);
        console.log('Success:', result);
    } catch (error) {
        console.error('Error:', error);
    }
});
