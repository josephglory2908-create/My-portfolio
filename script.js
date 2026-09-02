document.getElementById("year").textContent = new Date().getFullYear();

const buttons = document.querySelectorAll(".filter");
const skills = document.querySelectorAll(".skill-cloud span");

buttons.forEach((button) => {
  button.addEventListener("click", () => {
    buttons.forEach((item) => item.classList.remove("active"));
    button.classList.add("active");
    const selected = button.dataset.filter;
    skills.forEach((skill) => {
      skill.classList.toggle("hidden", selected !== "all" && skill.dataset.category !== selected);
    });
  });
});
