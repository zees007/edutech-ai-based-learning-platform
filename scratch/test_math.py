import asyncio
import httpx
import urllib.parse
import base64

async def test_math():
    math_tex = r"""\begin{aligned}
\nabla\cdot\mathbf{E} &= \frac{\rho}{\varepsilon_0} \\
\nabla\cdot\mathbf{B} &= 0 \\
\nabla\times\mathbf{E} &= -\frac{\partial\mathbf{B}}{\partial t} \\
\nabla\times\mathbf{B} &= \mu_0\mathbf{J}+\mu_0\varepsilon_0\frac{\partial\mathbf{E}}{\partial t}
\end{aligned}"""
    
    encoded = urllib.parse.quote(math_tex.strip())
    url = f"https://latex.codecogs.com/png.image?\\dpi{{200}}\\bg_white\\;{encoded}"
    
    print("URL:", url)
    async with httpx.AsyncClient(timeout=10.0) as client:
        resp = await client.get(url)
        print("Status:", resp.status_code)
        print("Len:", len(resp.content))
        if resp.status_code == 200:
            print("Base64 start:", base64.b64encode(resp.content).decode("ascii")[:30])

if __name__ == "__main__":
    asyncio.run(test_math())
