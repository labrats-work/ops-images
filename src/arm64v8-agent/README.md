## Environment Variables Documentation

To ensure the Docker container functions correctly and securely, it is essential to set the following environment variables when running the container. These variables are crucial for accessing the GitHub repository and specifying which repository and branch the container should work with.

### Required Environment Variables

- **`GITHUB_TOKEN`**: Your GitHub personal access token. This token is necessary for cloning private repositories or avoiding rate limits on public repositories. Ensure the token has the appropriate permissions for the actions you intend to perform.

- **`REPO_URL`**: The HTTPS URL of the GitHub repository to clone or fetch updates from. For example: `https://github.com/username/repository.git`

- **`BRANCH`** (Optional): The name of the branch you wish to monitor for changes. If not specified, it defaults to `main`.

### Running the Container with Environment Variables

To run the Docker container with the necessary environment variables, utilize the `-e` or `--env` flag for each variable during container execution. Here's an example command:

``` bash
docker run \ 
    -e GITHUB_TOKEN=your_github_token \
    -e REPO_URL=https://github.com/yourusername/yourrepo.git \
    -e BRANCH=main \
    ghcr.io/labrats-work/ops-images/arm64v8-agent arm64v8-agent
```

Replace:

- **your_github_token** with your actual GitHub personal access token.
- **https://github.com/yourusername/yourrepo.git** with your GitHub repository URL.
- **main** with your target branch name if different from main.

### Security Considerations

**Important:** Never hardcode your `GITHUB_TOKEN` or any other sensitive information in your Dockerfile or source code. Always provide sensitive data securely at runtime using environment variables or other secure methods.