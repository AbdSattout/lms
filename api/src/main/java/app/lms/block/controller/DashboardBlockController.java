package app.lms.block.controller;

import app.lms.block.dto.BlockResponse;
import app.lms.block.dto.CreateBlockRequest;
import app.lms.block.dto.ReorderBlocksRequest;
import app.lms.block.dto.UpdateBlockRequest;
import app.lms.block.service.DashboardBlockService;
import app.lms.security.UserPrincipal;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/dashboard")
@RequiredArgsConstructor
public class DashboardBlockController {

   private final DashboardBlockService dashboardBlockService;

    @PostMapping("/lessons/{lessonId}/blocks")
    public ResponseEntity<BlockResponse> create(

            @PathVariable Long lessonId,

            @RequestBody
            @Valid
            CreateBlockRequest request,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(
                        dashboardBlockService.create(
                                lessonId,
                                request,
                                principal.user()
                        )
                );
    }

    @PatchMapping("/blocks/{blockId}")
    public ResponseEntity<BlockResponse> update(

            @PathVariable Long blockId,

            @RequestBody
            @Valid
            UpdateBlockRequest request,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                dashboardBlockService.update(
                        blockId,
                        request,
                        principal.user()
                )
        );
    }

    @DeleteMapping("/blocks/{blockId}")
    public ResponseEntity<Void> delete(

            @PathVariable Long blockId,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        dashboardBlockService.delete(
                blockId,
                principal.user()
        );

        return ResponseEntity
                .noContent()
                .build();
    }

    @PatchMapping("/lessons/{lessonId}/blocks/reorder")
    public ResponseEntity<Void> reorder(

            @PathVariable Long lessonId,

            @RequestBody
            @Valid
            ReorderBlocksRequest request,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        dashboardBlockService.reorder(
                lessonId,
                request,
                principal.user()
        );

        return ResponseEntity
                .noContent()
                .build();
    }

    @GetMapping("/blocks/{blockId}")
    public ResponseEntity<?> getBlock(
            @PathVariable Long blockId,
            @AuthenticationPrincipal UserPrincipal principal
    ) {
       BlockResponse block= dashboardBlockService.getBlock(blockId , principal.user());
        return ResponseEntity.ok(block);
    }
    @GetMapping("/lessons/{lessonId}/blocks")
    public ResponseEntity<List<BlockResponse>> getBlocksByLessonId(
            @PathVariable Long lessonId,
            @AuthenticationPrincipal UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                dashboardBlockService.getBlocksByLessonId(
                        lessonId,
                        principal.user()
                )
        );
    }
}
