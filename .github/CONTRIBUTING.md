# Contributing to eSpeak NG Swift Package

Thank you for your interest in contributing! This document provides guidelines for contributing to this project.

## Branch Protection

The `main` branch is protected with the following rules:

### Required Status Checks
All pull requests must pass these CI checks before merging:
- **build-and-test** - Builds espeak-ng, Swift package, and runs tests on macOS
- **lint** - Validates code quality and file permissions
- **validation** - Checks for required files and security issues

### Pull Request Requirements
- At least **1 approving review** required before merging
- Stale reviews are automatically dismissed when new commits are pushed
- All conversations must be resolved before merging
- Branches must be up to date with main before merging

### Additional Protections
- Direct pushes to `main` are **not allowed**
- Force pushes are **disabled**
- Branch deletion is **disabled**
- Rules apply to **administrators** as well

## Development Workflow

1. **Fork the repository** or create a feature branch
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**
   - Follow Swift API design guidelines
   - Add tests for new functionality
   - Update documentation as needed

3. **Test locally**
   ```bash
   swift build
   swift test
   ```

4. **Commit your changes**
   ```bash
   git add .
   git commit -m "Description of your changes"
   ```

5. **Push to your fork/branch**
   ```bash
   git push origin feature/your-feature-name
   ```

6. **Open a Pull Request**
   - Fill out the PR template completely
   - Ensure all CI checks pass
   - Request review from maintainers
   - Address any review feedback

## Code Standards

### Swift Code
- Follow Swift API Design Guidelines
- Use clear, descriptive naming
- Add documentation comments for public APIs
- Maintain GPL-3.0 license compatibility

### Testing
- Add unit tests for new features
- Ensure existing tests pass
- Test on macOS (and iOS if applicable)
- Verify the package builds successfully

### Documentation
- Update README.md for user-facing changes
- Update USAGE.md for API changes
- Add inline code comments for complex logic
- Update CONTRIBUTING.md for process changes

## CI/CD Pipeline

Our CI pipeline runs automatically on:
- Every push to `main`
- Every pull request to `main`

The pipeline includes:
1. **Build espeak-ng** - Compiles the C library for macOS
2. **Build Swift package** - Compiles all Swift code
3. **Run tests** - Executes the test suite
4. **Lint checks** - Validates code quality
5. **Security checks** - Scans for potential secrets

## Getting Help

- Open an issue for bug reports or feature requests
- Tag your issue appropriately (bug, enhancement, question, etc.)
- Provide detailed information and reproduction steps for bugs
- Check existing issues before creating a new one

## License

By contributing, you agree that your contributions will be licensed under the GPL-3.0 License, maintaining compatibility with eSpeak NG.
