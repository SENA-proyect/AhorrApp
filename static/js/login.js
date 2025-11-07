        // Código de un Shader de ejemplo muy simple para el Vertex Shader
const VERTEX_SHADER_SOURCE = `
            attribute vec4 a_position;
            void main() {
                gl_Position = a_position;
            }
`;
        
const FRAGMENT_SHADER_SOURCE = document.getElementById('fragShader').textContent;

function createShader(gl, type, source) {
            const shader = gl.createShader(type);
            gl.shaderSource(shader, source);
            gl.compileShader(shader);
            if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
                console.error('Error compiling shader:', gl.getShaderInfoLog(shader));
                gl.deleteShader(shader);
                return null;
            }
            return shader;
}

function createProgram(gl, vertexShader, fragmentShader) {
            const program = gl.createProgram();
            gl.attachShader(program, vertexShader);
            gl.attachShader(program, fragmentShader);
            gl.linkProgram(program);
            if (!gl.getProgramParameter(program, gl.LINK_STATUS)) {
                console.error('Error linking program:', gl.getProgramInfoLog(program));
                gl.deleteProgram(program);
                return null;
            }
            return program;
}
        
const canvas = document.getElementById('shaderCanvas');
const gl = canvas.getContext('webgl') || canvas.getContext('experimental-webgl');

if (!gl) {
            console.error('WebGL no es soportado por este navegador.');
} else {
            const vertexShader = createShader(gl, gl.VERTEX_SHADER, VERTEX_SHADER_SOURCE);
            const fragmentShader = createShader(gl, gl.FRAGMENT_SHADER, FRAGMENT_SHADER_SOURCE);
            const program = createProgram(gl, vertexShader, fragmentShader);

            gl.useProgram(program);

            // Búsqueda de uniformes y atributos
            const resolutionLocation = gl.getUniformLocation(program, "iResolution");
            const timeLocation = gl.getUniformLocation(program, "iTime");
            const positionLocation = gl.getAttribLocation(program, "a_position");

            // Crear buffer para un rectángulo que cubra toda la pantalla (el plano de renderizado)
            const positionBuffer = gl.createBuffer();
            gl.bindBuffer(gl.ARRAY_BUFFER, positionBuffer);
            const positions = [
                -1, -1, // Triángulo 1
                 1, -1,
                -1,  1,
                -1,  1, // Triángulo 2
                 1, -1,
                 1,  1,
            ];
            gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(positions), gl.STATIC_DRAW);

            // Configurar el atributo de posición
            gl.enableVertexAttribArray(positionLocation);
            gl.vertexAttribPointer(positionLocation, 2, gl.FLOAT, false, 0, 0);

            let startTime = performance.now();

            function draw() {
                // Actualizar tamaño del canvas al tamaño de la ventana
                canvas.width = window.innerWidth;
                canvas.height = window.innerHeight;
                gl.viewport(0, 0, gl.canvas.width, gl.canvas.height);

                // Actualizar uniformes
                gl.uniform2f(resolutionLocation, gl.canvas.width, gl.canvas.height);
                const currentTime = (performance.now() - startTime) / 1000.0; // Tiempo en segundos
                gl.uniform1f(timeLocation, currentTime);

                // Dibujar
                gl.drawArrays(gl.TRIANGLES, 0, 6);

                // Bucle de renderizado
                requestAnimationFrame(draw);
            }

            draw(); // Iniciar el bucle
            window.addEventListener('resize', draw); // Redimensionar al cambiar el tamaño de la ventana
}
